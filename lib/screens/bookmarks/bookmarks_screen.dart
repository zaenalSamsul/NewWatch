import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/providers/auth_provider.dart';
import 'package:newswatch/services/api_service.dart';
import 'package:newswatch/widgets/article_card.dart';
import 'package:provider/provider.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Article>>? _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    // Gunakan WidgetsBinding untuk memastikan context sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookmarks();
    });
  }

  void _fetchBookmarks() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      setState(() {
        _bookmarksFuture = _apiService.getSavedArticles(token);
      });
    }
  }

  void _removeBookmarkAndRefresh(String articleId) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      await _apiService.removeBookmark(articleId, token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark removed'),
          backgroundColor: Colors.green,
        ),
      );
      // Panggil lagi API untuk refresh data
      _fetchBookmarks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: FutureBuilder<List<Article>>(
        future: _bookmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error.toString()}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final bookmarkedArticles = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _fetchBookmarks(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedArticles.length,
              itemBuilder: (context, index) {
                final article = bookmarkedArticles[index];
                // Set isBookmarked ke true karena ini adalah halaman bookmark
                // dan berikan fungsi untuk menghapus bookmark
                return ArticleCard(
                  article: article,
                  onBookmarkPressed:
                      () => _removeBookmarkAndRefresh(article.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.bookmark, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'No saved articles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bookmark articles to read them later',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
