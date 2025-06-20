import 'package:flutter/foundation.dart';

@immutable
class Author {
  final String name;
  final String? title;
  final String? avatar;

  const Author({required this.name, this.title, this.avatar});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'] as String,
      title: json['title'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}

@immutable
class Article {
  final String id;
  final String title;
  final String category;
  final String publishedAt;
  final String? readTime;
  final String imageUrl;
  final bool isTrending;
  final List<String> tags;
  final String content;
  final Author author;
  final DateTime createdAt;
  final bool? isBookmarked;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedAt,
    this.readTime,
    required this.imageUrl,
    required this.isTrending,
    required this.tags,
    required this.content,
    required this.author,
    required this.createdAt,
    this.isBookmarked,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
  return Article(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    publishedAt: json['publishedAt'] as String,
    readTime: json['readTime'] as String?,
    imageUrl: json['imageUrl'] as String,
    isTrending: json['isTrending'] as bool? ?? false,
    tags: List<String>.from(json['tags'] as List),
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isBookmarked: json['isBookmarked'] as bool?,

    // ================================================================
    // PERBAIKAN UTAMA DI SINI
    // Kita cek dulu apakah json['author'] itu null atau tidak
    // ================================================================
    author: json['author'] != null
        // Jika TIDAK null, parse seperti biasa
        ? Author.fromJson(json['author'] as Map<String, dynamic>)
        // Jika NULL, buat objek Author default agar tidak error
        : const Author(name: 'Unknown Author', avatar: null, title: null),
    // ================================================================
  );
}
  
  // Untuk membuat body request saat membuat artikel baru
  Map<String, dynamic> toJsonForCreate() {
    return {
      'title': title,
      'category': category,
      'readTime': readTime,
      'imageUrl': imageUrl,
      'isTrending': isTrending,
      'tags': tags,
      'content': content,
    };
  }
}