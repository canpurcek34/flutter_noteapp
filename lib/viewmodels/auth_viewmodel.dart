// viewmodels/auth_viewmodel.dart
import 'package:flutter/material.dart';
import '../authpages/auth_screen.dart';

class AuthViewModel extends ChangeNotifier {

  Widget _authScreen = const AuthScreen();

   Widget get authScreen => _authScreen;

  void setAuthScreen() {
    _authScreen = const AuthScreen();
    notifyListeners();
  }

}