import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/utils/app_routes.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onBookmarkPressed;

  const ArticleCard({super.key, required this.article, this.onBookmarkPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.articleDetail,
          arguments: article,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.error),
                        ),
                  ),
                ),
                if (onBookmarkPressed != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withAlpha((0.8 * 255).toInt()),
                      child: IconButton(
                        icon: Icon(
                          // Asumsi state `isBookmarked` akan dikelola oleh parent widget
                          article.isBookmarked == true
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: theme.primaryColor,
                        ),
                        onPressed: onBookmarkPressed,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(article.category),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 12,
                        ),
                        backgroundColor:
                            isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                        side: BorderSide.none,
                      ),
                      Text(
                        article.publishedAt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage:
                            article.author.avatar != null
                                ? CachedNetworkImageProvider(
                                  article.author.avatar!,
                                )
                                : null,
                        child:
                            article.author.avatar == null
                                ? const Icon(LucideIcons.user, size: 12)
                                : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article.author.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
