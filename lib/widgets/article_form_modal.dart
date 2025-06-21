import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/providers/article_provider.dart';
import 'package:provider/provider.dart';

class ArticleFormModal extends StatefulWidget {
  final Article? article;
  const ArticleFormModal({super.key, this.article});

  @override
  State<ArticleFormModal> createState() => _ArticleFormModalState();
}

class _ArticleFormModalState extends State<ArticleFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _imageUrlController;
  late String _selectedCategory;
  late bool _isTrending;

  final List<String> _categories = [
    "Technology",
    "Business",
    "Politics",
    "Sports",
    "Health"
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi nilai form berdasarkan artikel yang ada (mode edit)
    // atau dengan nilai default (mode create)
    final article = widget.article;
    _titleController = TextEditingController(text: article?.title);
    _contentController = TextEditingController(text: article?.content);
    _imageUrlController = TextEditingController(text: article?.imageUrl);
    _selectedCategory = article?.category ?? 'Technology';
    _isTrending = article?.isTrending ?? false;

    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
      final articleData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'category': _selectedCategory,
        'tags': [_selectedCategory.toLowerCase(), 'new'],
        'readTime': '5 menit',
        'isTrending': _isTrending,
      };

      try {
        // Simpan referensi Navigator dan ScaffoldMessenger sebelum async call
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        if (widget.article == null) {
          // Mode Create
          await articleProvider.createArticle(articleData);
          navigator.pop(); // Tutup modal
          _showSuccessDialog();
        } else {
          // Mode Update
          await articleProvider.updateArticle(widget.article!.id, articleData);
          navigator.pop(); // Tutup modal
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Article updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          icon: const Icon(LucideIcons.checkCircle2,
              color: Colors.green, size: 48),
          title: const Text('Berhasil!',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Artikel baru telah berhasil dibuat.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.article == null ? 'Create New Article' : 'Edit Article',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  if (v.trim().length < 5) return 'Title must be at least 5 characters';
                  if (v.trim().length > 200) return 'Title must not exceed 200 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Content is required';
                  if (v.trim().length < 100) return 'Content must be at least 100 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Image URL is required';
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.isAbsolute) {
                    return 'Please enter a valid URL format (e.g. https://...)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("Is Trending?"),
                value: _isTrending,
                onChanged: (newValue) => setState(() => _isTrending = newValue),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(widget.article == null ? LucideIcons.plusCircle : LucideIcons.save),
                label: Text(widget.article == null ? 'Create Article' : 'Update Article'),
                onPressed: _submitForm,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}