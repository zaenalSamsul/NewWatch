import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/providers/article_provider.dart';
import 'package:newswatch/providers/auth_provider.dart';
import 'package:newswatch/widgets/article_card.dart';
import 'package:newswatch/widgets/trending_carousel.dart';
import 'package:provider/provider.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  final List<String> _categories = ["All", "Technology", "Business", "Politics", "Sports", "Health"];
  String _selectedCategory = "All";

  Future<void> _onRefresh() async {
    await Provider.of<ArticleProvider>(context, listen: false).fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'NewsWatch',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (user != null)
              Builder(
                builder: (context) {
                  final hour = DateTime.now().hour;
                  String greeting;
                  if (hour < 12) {
                    greeting = 'Selamat pagi';
                  } else if (hour < 18) {
                    greeting = 'Selamat siang';
                  } else {
                    greeting = 'Selamat malam';
                  }
                  return Text(
                    '$greeting, ${user.name}!',
                    style: theme.textTheme.bodySmall,
                  );
                },
              ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Trending",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const TrendingCarousel(),
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                             _selectedCategory = category;
                          });
                        }
                      },
                      selectedColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : null,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ArticleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.articles.isEmpty) {
                  return const Center(
                    child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()),
                  );
                }

                final articles = _selectedCategory == 'All'
                    ? provider.articles
                    : provider.articles.where((a) => a.category == _selectedCategory).toList();

                if (articles.isEmpty) {
                  return const Center(child: Text("No articles found in this category."));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(article: articles[index]);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}