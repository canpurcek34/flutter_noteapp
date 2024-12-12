import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

    Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
      final prefs = await SharedPreferences.getInstance();
       await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode ? ThemeData.dark(useMaterial3:true).copyWith(
             colorScheme: ColorScheme.dark(
             primary: Colors.cyan.shade300,
              secondary: Colors.cyanAccent.shade200,
               surface: Colors.grey.shade800,
                background: Colors.grey.shade900,
            )
             ) : ThemeData.light(useMaterial3: true).copyWith(
               colorScheme: ColorScheme.light(
                 primary: Colors.cyan,
                 secondary: Colors.cyanAccent,
                 surface: Colors.white,
                 background: Colors.white
             ),
                 );
  }
}

