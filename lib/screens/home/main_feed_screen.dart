import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/providers/auth_provider.dart';
import 'package:newswatch/services/api_service.dart';
import 'package:newswatch/widgets/article_card.dart';
import 'package:newswatch/widgets/trending_carousel.dart';
import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Article>>? _articlesFuture;

  // Di dalam file: lib/screens/home/main_feed_screen.dart

  final List<String> _categories = [
    "All",
    "Technology",
    "Business",
    "Politics",
    "Sports",
    "Health",
  ];
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  void _fetchArticles() {
    setState(() {
      _articlesFuture = _apiService.getAllArticles(category: _selectedCategory);
    });
  }

  Future<void> _onRefresh() async {
    // Cukup panggil _fetchArticles untuk me-refresh dengan kategori yang sedang dipilih
    _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        title: Column(
          // Mengubah Row menjadi Column untuk menumpuk elemen secara vertikal
          crossAxisAlignment:
              CrossAxisAlignment.start, // Sejajarkan konten ke awal (kiri)
          children: [
            Row(
              // Row asli untuk logo dan nama aplikasi
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image.asset(
                    'assets/images/logo.png', // Ganti dengan path yang benar ke aset logo Anda
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'NewsWatch',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const TrendingCarousel(),
            const SizedBox(height: 24),

            // Filter Kategori
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
                          _selectedCategory = category;
                          _fetchArticles();
                        }
                      },
                      selectedColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : null,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color:
                            isSelected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Artikel Terbaru
            FutureBuilder<List<Article>>(
              future: _articlesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}",
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No articles found in this category."),
                  );
                }

                final articles = snapshot.data!;

                // ================================================================
                // PERBAIKAN UTAMA DI SINI: Urutkan daftar artikel
                // Kita urutkan berdasarkan `createdAt` dari yang terbaru (descending)
                articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                // ================================================================

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
