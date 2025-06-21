import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newswatch/models/article.dart';
import 'package:newswatch/models/user.dart';

class ApiService {
  static const String _baseUrl = "https://rest-api-berita.vercel.app/api/v1";

  // --- PENYEMPURNAAN ERROR HANDLING ---
  // Memberikan pesan error yang lebih detail.
  Exception _handleError(http.Response response) {
    try {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? 'An unknown error occurred.';
      final detailedError = errorBody['error'] != null ? ' Details: ${errorBody['error']}' : '';
      return Exception('$message$detailedError');
    } catch (e) {
      return Exception('Failed to parse error response. Status code: ${response.statusCode}');
    }
  }

  Map<String, String> _getAuthHeaders(String token) => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };

  // --- Authentication ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'user': User.fromJson(body['data']['user']),
          'token': body['data']['token'],
        };
      } else {
        throw Exception(body['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to connect or process the request.');
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? title,
    String? avatar,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'title': title ?? 'News Enthusiast',
          'avatar': avatar ?? 'https://ui-avatars.com/api/?name=$name',
        }),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 201 && body['success'] == true) {
        return {
          'user': User.fromJson(body['data']['user']),
          'token': body['data']['token'],
        };
      } else {
        throw Exception(body['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Failed to connect or process the request.');
    }
  }
  // --- Articles by User ---
  Future<List<Article>> getMyArticles(String token) async {
    final uri = Uri.parse('$_baseUrl/news/user/me');
    final response = await http.get(
      uri,
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List articlesJson = body['data']['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      }
    }
    // Gunakan _handleError untuk konsistensi penanganan error
    throw _handleError(response);
  }

  // --- Articles ---
  Future<List<Article>> getAllArticles({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    final queryParameters = {
      'page': '$page',
      'limit': '$limit',
      if (category != null && category.toLowerCase() != 'all') 'category': category,
    };
    final uri = Uri.parse('$_baseUrl/news').replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List articlesJson = body['data']['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      }
    }
    throw _handleError(response);
  }

  Future<List<Article>> getTrendingArticles() async {
    final uri = Uri.parse('$_baseUrl/news/trending');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List articlesJson = body['data']['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      }
    }
    throw _handleError(response);
  }
  
  // --- Bookmarks ---
  Future<List<Article>> getSavedArticles(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/news/bookmarks/list'),
      headers: _getAuthHeaders(token),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List articlesJson = body['data']['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      }
    }
    throw _handleError(response);
  }

  Future<void> saveBookmark(String articleId, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/news/$articleId/bookmark'),
      headers: _getAuthHeaders(token),
    );
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  Future<void> removeBookmark(String articleId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/news/$articleId/bookmark'),
      headers: _getAuthHeaders(token),
    );
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  // --- CRUD by Admin/Author ---
  Future<Article> createArticle(Map<String, dynamic> articleData, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/news'),
      headers: _getAuthHeaders(token),
      body: jsonEncode(articleData),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return Article.fromJson(body['data']);
      }
    }
    throw _handleError(response);
  }

  Future<Article> updateArticle(String articleId, Map<String, dynamic> articleData, String token) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/news/$articleId'),
      headers: _getAuthHeaders(token),
      body: jsonEncode(articleData),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return Article.fromJson(body['data']);
      }
    }
    throw _handleError(response);
  }

  Future<void> deleteArticle(String articleId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/news/$articleId'),
      headers: _getAuthHeaders(token),
    );
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }
}