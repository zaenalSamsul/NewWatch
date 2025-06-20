import 'package:flutter/material.dart';
import 'package:newswatch/providers/auth_provider.dart';
import 'package:newswatch/providers/theme_provider.dart';
import 'package:newswatch/screens/auth/splash_screen.dart';
import 'package:newswatch/utils/app_routes.dart';
import 'package:newswatch/utils/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Gunakan MultiProvider untuk mendaftarkan semua provider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Memuat tema saat aplikasi pertama kali dibangun
    Provider.of<ThemeProvider>(context, listen: false).loadTheme();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'NewsWatch',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(), // Mulai dari splash screen
          routes: AppRoutes.getRoutes(),
        );
      },
    );
  }
}
