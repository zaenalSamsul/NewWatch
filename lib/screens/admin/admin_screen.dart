import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/providers/article_provider.dart';
import 'package:newswatch/widgets/article_form_modal.dart'; // <-- 1. Import widget baru
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // 2. Hapus fungsi _showSuccessDialog dari sini, karena sudah pindah ke dalam modal

  Future<void> _deleteArticle(String articleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this article?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<ArticleProvider>(context, listen: false).deleteArticle(articleId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article deleted successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 3. Ganti fungsi _showArticleForm yang panjang dengan yang simpel ini
  void _showArticleForm({Article? article}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      // Cukup panggil widget yang sudah kita buat
      builder: (ctx) => ArticleFormModal(article: article),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchAll(),
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.articles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.articles.isEmpty) {
                  return const Center(child: Text("No articles found."));
                }
                final articles = provider.articles;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(article.imageUrl)),
                        title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(article.category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.edit, size: 20, color: Colors.blue),
                              onPressed: () => _showArticleForm(article: article),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
                              onPressed: () => _deleteArticle(article.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
}