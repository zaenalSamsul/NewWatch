import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/providers/auth_provider.dart';
import 'package:newswatch/services/api_service.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Article>>? _articlesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _articlesFuture = _apiService.getAllArticles(limit: 50);
    });
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          icon: Icon(LucideIcons.checkCircle2, color: Colors.green, size: 48),
          title: const Text(
            'Berhasil!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Artikel baru telah berhasil dibuat.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteArticle(String articleId) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
              'Are you sure you want to delete this article?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteArticle(articleId, token);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showArticleForm({Article? article}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: article?.title);
    final contentController = TextEditingController(text: article?.content);
    final imageUrlController = TextEditingController(text: article?.imageUrl);
    String selectedCategory = article?.category ?? 'Technology';

    final categories = [
      "Technology",
      "Business",
      "Politics",
      "Sports",
      "Health",
    ];

    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      article == null ? 'Create New Article' : 'Edit Article',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator:
                          (v) => v!.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Content'),
                      maxLines: 5,
                      validator:
                          (v) =>
                              v!.trim().isEmpty ? 'Content is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      validator: (v) {
                        final url = v!.trim();
                        if (url.isEmpty) return 'Image URL is required';
                        final uri = Uri.tryParse(url);
                        if (uri == null || !uri.hasAbsolutePath) {
                          return 'Please enter a valid URL';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) selectedCategory = value;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: Icon(
                        article == null
                            ? LucideIcons.plusCircle
                            : LucideIcons.save,
                      ),
                      label: Text(
                        article == null ? 'Create Article' : 'Update Article',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final token =
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).token;
                          if (token == null) return;

                          final articleData = {
                            'title': titleController.text.trim(),
                            'content': contentController.text.trim(),
                            'imageUrl': imageUrlController.text.trim(),
                            'category': selectedCategory,
                            'tags': [selectedCategory.toLowerCase(), 'new'],
                            'readTime': '5 menit',
                          };

                          try {
                            final navigator = Navigator.of(ctx);
                            final messenger = ScaffoldMessenger.of(context);

                            if (article == null) {
                              await _apiService.createArticle(
                                articleData,
                                token,
                              );
                              if (!mounted) return;
                              navigator.pop();
                              _showSuccessDialog();
                            } else {
                              await _apiService.updateArticle(
                                article.id,
                                articleData,
                                token,
                              );
                              if (!mounted) return;
                              navigator.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Article updated successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }

                            _refreshData();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: FutureBuilder<List<Article>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No articles found."));
            }

            final articles = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(article.imageUrl),
                    ),
                    title: Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(article.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            LucideIcons.edit,
                            size: 20,
                            color: Colors.blue,
                          ),
                          onPressed: () => _showArticleForm(article: article),
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 20,
                            color: Colors.red,
                          ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showArticleForm(),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
