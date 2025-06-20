import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/screens/admin/admin_screen.dart'; // Import halaman admin
import 'package:newswatch/screens/bookmarks/bookmarks_screen.dart';
import 'package:newswatch/screens/home/main_feed_screen.dart';
import 'package:newswatch/screens/profile/profile_screen.dart';
import 'package:newswatch/screens/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Tambahkan AdminScreen ke dalam daftar halaman
  static final List<Widget> _pages = <Widget>[
    const MainFeedScreen(),
    const SearchScreen(),
    const BookmarksScreen(),
    const AdminScreen(), // Halaman baru ditambahkan di sini
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.bookmark), label: 'Saved'),
          // Tambahkan item navigasi untuk Admin
          BottomNavigationBarItem(icon: Icon(LucideIcons.shield), label: 'Admin'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}