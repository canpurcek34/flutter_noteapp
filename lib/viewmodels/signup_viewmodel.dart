// viewmodels/signup_viewmodel.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/authpages/login_screen.dart';

class SignUpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  
  Future<void> signUp(BuildContext context, String email, String password,
      String fullName, String userName) async {
          _isLoading = true;
          notifyListeners();
      try {
           UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
            await userCredential.user?.updateDisplayName(fullName);
            await userCredential.user?.sendEmailVerification();

          _showSuccessDialog(context);
        } on FirebaseAuthException catch (e) {
      String errorMessage = 'Kayıt sırasında bir hata oluştu';
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf';
          break;
        case 'email-already-in-use':
          errorMessage = 'Bu e-posta adresi zaten kullanımda';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
      }

     _showErrorSnackBar(context,errorMessage);
    } catch (e) {
       _showErrorSnackBar(context,'Beklenmedik bir hata oluştu');
    } finally {
        _isLoading = false;
       notifyListeners();
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kayıt Başarılı'),
        content: const Text(
          'Hesabınız oluşturuldu. Lütfen e-posta adresinizi doğrulayın.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Giriş Ekranına Git'),
          ),
        ],
      ),
    );
  }

    void navigateToLogin(BuildContext context) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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