import 'package:flutter/material.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/services/api_service.dart';

class ArticleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String? _token;

  // --- State untuk Artikel Umum ---
  List<Article> _articles = [];
  List<Article> get articles => _articles;

  // --- State untuk Bookmark ---
  List<Article> _bookmarkedArticles = [];
  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  
  // --- State Loading Umum ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // =======================================================================
  // TAMBAHAN: State terpisah untuk "My Articles"
  // =======================================================================
  List<Article> _myArticles = [];
  List<Article> get myArticles => _myArticles;

  bool _isMyArticlesLoading = false;
  bool get isMyArticlesLoading => _isMyArticlesLoading;
  // =======================================================================

  ArticleProvider(this._token) {
    if (_token != null) {
      fetchAll();
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final allArticles = await _apiService.getAllArticles(limit: 100);
      allArticles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _articles = allArticles;

      if (_token != null) {
        _bookmarkedArticles = await _apiService.getSavedArticles(_token!);
      }
    } catch (e) {
      print(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  // =======================================================================
  // TAMBAHAN: Fungsi baru untuk mengambil data dari endpoint /news/user/me
  // Pastikan Anda sudah menambahkan getMyArticles() di api_service.dart
  // =======================================================================
  Future<void> fetchMyArticles() async {
    if (_token == null) return;
    _isMyArticlesLoading = true;
    notifyListeners();

    try {
      _myArticles = await _apiService.getMyArticles(_token!);
      // Anda bisa menambahkan sort di sini jika perlu
      _myArticles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print("Error fetching my articles: $e");
      _myArticles = [];
    }

    _isMyArticlesLoading = false;
    notifyListeners();
  }
  // =======================================================================

  Future<void> createArticle(Map<String, dynamic> articleData) async {
    if (_token == null) throw Exception("User not authenticated");
    await _apiService.createArticle(articleData, _token!);
    
    // UBAH: Panggil kedua fetch untuk sinkronisasi data
    await fetchMyArticles();
    await fetchAll();
  }

  Future<void> updateArticle(String articleId, Map<String, dynamic> articleData) async {
    if (_token == null) throw Exception("User not authenticated");
    await _apiService.updateArticle(articleId, articleData, _token!);

    // UBAH: Panggil kedua fetch untuk sinkronisasi data
    await fetchMyArticles();
    await fetchAll();
  }

  Future<void> deleteArticle(String articleId) async {
    if (_token == null) throw Exception("User not authenticated");
    await _apiService.deleteArticle(articleId, _token!);

    // UBAH: Panggil kedua fetch untuk sinkronisasi data
    await fetchMyArticles();
    await fetchAll();
  }

  Future<void> toggleBookmark(String articleId) async {
    if (_token == null) throw Exception("User not authenticated");

    final isBookmarked = _bookmarkedArticles.any((a) => a.id == articleId);

    try {
      if (isBookmarked) {
        await _apiService.removeBookmark(articleId, _token!);
      } else {
        await _apiService.saveBookmark(articleId, _token!);
      }
      // Cukup refresh daftar bookmark saja, tidak perlu fetchAll
      _bookmarkedArticles = await _apiService.getSavedArticles(_token!);
      notifyListeners();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}