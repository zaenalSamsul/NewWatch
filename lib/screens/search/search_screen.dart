import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/services/api_service.dart';
import 'package:newswatch/widgets/article_card.dart';

// Kelas kecil untuk debounce (menunda eksekusi)
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  List<Article> _allArticles = [];
  List<Article> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllArticlesForSearch();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadAllArticlesForSearch() async {
    setState(() => _isLoading = true);
    try {
      // Ambil semua artikel sekali saja untuk di-filter
      _allArticles = await _apiService.getAllArticles(
        limit: 100,
      ); // Ambil lebih banyak untuk pencarian
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoading = false);
  }

  void _onSearchChanged() {
    if (_searchController.text != _searchQuery) {
      _debouncer.run(() {
        if (_searchController.text.isEmpty) {
          setState(() {
            _searchResults = [];
            _searchQuery = '';
          });
        } else {
          setState(() {
            _searchQuery = _searchController.text;
            _searchResults =
                _allArticles
                    .where(
                      (article) =>
                          article.title.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          article.content.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Articles')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for news...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 20),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchQuery.isEmpty
                    ? _buildInitialView()
                    : _buildResultsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.searchCode, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Search for any topic',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Results will appear here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Try different keywords.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ArticleCard(article: _searchResults[index]);
      },
    );
  }
}
