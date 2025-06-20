import 'package:flutter/material.dart';
import 'package:newswatch/screens/article/article_detail_screen.dart';
import 'package:newswatch/screens/auth/introduction_screen.dart';
import 'package:newswatch/screens/auth/login_screen.dart';
import 'package:newswatch/screens/auth/register_screen.dart';
import 'package:newswatch/screens/home/home_screen.dart';
import 'package:newswatch/screens/profile/edit_profile_screen.dart';
import 'package:newswatch/screens/profile/profile_screen.dart';

class AppRoutes {
  static const String introduction = '/introduction';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String articleDetail = '/article-detail';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      introduction: (context) => const IntroductionScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      articleDetail: (context) => const ArticleDetailScreen(),
    };
  }
}
