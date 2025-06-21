import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/providers/article_provider.dart';
import 'package:newswatch/widgets/article_card.dart';
import 'package:provider/provider.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.bookmarkedArticles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.bookmarkedArticles.isEmpty) {
            return _buildEmptyState();
          }

          final bookmarkedArticles = provider.bookmarkedArticles;
          return RefreshIndicator(
            onRefresh: () => provider.fetchAll(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedArticles.length,
              itemBuilder: (context, index) {
                final article = bookmarkedArticles[index];
                return ArticleCard(
                  article: article,
                  onBookmarkPressed: () async {
                    try {
                      await provider.toggleBookmark(article.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bookmark removed'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  },
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
          const Text('No saved articles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Bookmark articles to read them later', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}