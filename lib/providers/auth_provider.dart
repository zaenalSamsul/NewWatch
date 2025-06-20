import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newswatch/models/user.dart';
import 'package:newswatch/services/api_service.dart';
//import 'package:newswatch/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  User? _user;
  bool _isLoggedIn = false;

  String? get token => _token;
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  // Method untuk menyimpan data sesi ke SharedPreferences
  Future<void> _persistAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    // Simpan data user sebagai string JSON untuk kemudahan
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  // Method ini akan dipanggil saat aplikasi pertama kali dibuka
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false; // Tidak ada token, tidak bisa auto login
    }
    
    _token = prefs.getString('token');
    final extractedUserData = jsonDecode(prefs.getString('user')!) as Map<String, dynamic>;
    _user = User.fromJson(extractedUserData);
    _isLoggedIn = true;
    
    notifyListeners();
    return true;
  }
  
  Future<void> login(String email, String password) async {
    try {
      final authData = await _apiService.login(email, password);
      _token = authData['token'] as String;
      _user = authData['user'] as User;
      _isLoggedIn = true;
      
      await _persistAuthData(_token!, _user!);
      notifyListeners();
    } catch (e) {
      // Lempar kembali error agar bisa ditangkap dan ditampilkan di UI
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _isLoggedIn = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data dari SharedPreferences
    
    notifyListeners();
  }
}