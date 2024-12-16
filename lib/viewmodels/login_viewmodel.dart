// viewmodels/login_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_noteapp/ui/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _keepLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get keepLoggedIn => _keepLoggedIn;

  void setKeepLoggedIn(bool value) {
    _keepLoggedIn = value;
     notifyListeners();
  }
    Future<void> login(BuildContext context, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
           if (_keepLoggedIn) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
        }
        if (!user.emailVerified) {
          await _auth.signOut();
           _showErrorSnackBar(context, 'E-posta adresinizi doğrulayın');
        } else {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Giriş başarısız';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Kullanıcı bulunamadı';
          break;
        case 'wrong-password':
          errorMessage = 'Hatalı şifre';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
      }
     _showErrorSnackBar(context, errorMessage);
    } catch (e) {
        _showErrorSnackBar(context,'Bir hata oluştu');
    } finally {
      _isLoading = false;
       notifyListeners();
    }
  }


  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}