import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String email;
  final String name;
  final String? title;
  final String? avatar;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.title,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      title: json['title'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'title': title,
      'avatar': avatar,
    };
  }
}