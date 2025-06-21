import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/providers/article_provider.dart';
import 'package:newswatch/widgets/article_form_modal.dart';
import 'package:provider/provider.dart';

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});

  @override
  State<MyArticlesScreen> createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fetchMyArticles() saat halaman pertama kali dibuka
    // 'listen: false' agar tidak rebuild saat dipanggil di initState
    Future.microtask(() =>
        Provider.of<ArticleProvider>(context, listen: false).fetchMyArticles());
  }

  void _showArticleForm({Article? article}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ArticleFormModal(article: article),
    );
  }

  Future<void> _deleteArticle(String articleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<ArticleProvider>(context, listen: false)
            .deleteArticle(articleId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Artikel berhasil dihapus'),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Articles'),
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          // Gunakan state loading yang baru
          if (articleProvider.isMyArticlesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Gunakan list yang sudah didedikasikan
          final myArticles = articleProvider.myArticles;

          if (myArticles.isEmpty) {
            return _buildEmptyState();
          }

          // Tarik untuk refresh
          return RefreshIndicator(
            onRefresh: () => articleProvider.fetchMyArticles(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: myArticles.length,
              itemBuilder: (context, index) {
                final article = myArticles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(article.imageUrl),
                    ),
                    title: Text(article.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(article.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.edit,
                              size: 20, color: Colors.blue),
                          onPressed: () => _showArticleForm(article: article),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2,
                              size: 20, color: Colors.red),
                          onPressed: () => _deleteArticle(article.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showArticleForm(),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.fileText, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text('You haven\'t written any articles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Click the + button to create your first article',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}