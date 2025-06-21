import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/providers/article_provider.dart';
import 'package:provider/provider.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final article = ModalRoute.of(context)!.settings.arguments as Article;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              centerTitle: true,
              title: Text(
                article.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: CachedNetworkImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withAlpha((0.4 * 255).round()),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            actions: [
              Consumer<ArticleProvider>(
                builder: (context, provider, child) {
                  final isBookmarked = provider.bookmarkedArticles.any((a) => a.id == article.id);
                  return IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? theme.primaryColor : Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        await provider.toggleBookmark(article.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isBookmarked ? 'Bookmark removed' : 'Article saved!'),
                            backgroundColor: Colors.green,
                          ),
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
              IconButton(
                icon: const Icon(LucideIcons.share2, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(label: Text(article.category)),
                      Text(
                        article.publishedAt,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(article.author.avatar!),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.author.name,
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            article.author.title ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    article.content,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    children: article.tags.map((tag) => Chip(label: Text('#$tag'))).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}