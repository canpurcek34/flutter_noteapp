import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();
  bool _isDarkMode = false;

  // Constructor
  ThemeProvider() {
    _initializeTheme();
  }

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  Future<void> _initializeTheme() async {
    final brightness = PlatformDispatcher.instance.platformBrightness;
    _isDarkMode = brightness == Brightness.dark;
    await _loadTheme();
    _updateTheme();
  }


  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? _isDarkMode;
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    _updateTheme();
    notifyListeners();
  }

  void _updateTheme() {
    _currentTheme = _isDarkMode
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.cyan,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[850],
              elevation: 4,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyan,
              secondary: Colors.cyanAccent,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.cyan,
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.cyan,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.cyan,
              elevation: 4,
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.cyan,
              secondary: Colors.cyanAccent,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.cyan,
            ),
          );
          notifyListeners();
  }
}
