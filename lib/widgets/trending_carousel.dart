import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:newswatch/models/article.dart';
import 'package:newswatch/services/api_service.dart';
import 'package:newswatch/utils/app_routes.dart';

class TrendingCarousel extends StatefulWidget {
  const TrendingCarousel({super.key});

  @override
  State<TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<TrendingCarousel> {
  final ApiService _apiService = ApiService();
  late Future<List<Article>> _trendingFuture;

  @override
  void initState() {
    super.initState();
    _trendingFuture = _apiService.getTrendingArticles();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: _trendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('Could not load trending news')),
          );
        }

        final trendingArticles = snapshot.data!;

        return CarouselSlider.builder(
          itemCount: trendingArticles.length,
          itemBuilder: (context, index, realIndex) {
            final article = trendingArticles[index];
            return GestureDetector(
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.articleDetail,
                    arguments: article,
                  ),
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        imageUrl: article.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withAlpha((0.7 * 255).toInt()),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            label: Text(
                              article.category,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.white.withAlpha(
                              (0.2 * 255).toInt(),
                            ),
                            side: BorderSide.none,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
          ),
        );
      },
    );
  }
}
