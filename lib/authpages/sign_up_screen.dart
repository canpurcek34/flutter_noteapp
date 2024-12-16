// authpages/SignScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/viewmodels/signup_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: _SignUpScreenContent(),
    );
  }
}

class _SignUpScreenContent extends StatefulWidget {
  @override
  _SignUpScreenContentState createState() => _SignUpScreenContentState();
}

class _SignUpScreenContentState extends State<_SignUpScreenContent> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
   final _formKey = GlobalKey<FormState>();
   bool _obscurePassword = true;

    @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    fullNameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Başlık
                  Text(
                    'Hesap Oluştur',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),
                  // E-posta TextField
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-posta boş bırakılamaz';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Kullanıcı Adı TextField
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kullanıcı adı boş bırakılamaz';
                      }
                      if (value.length < 3) {
                        return 'Kullanıcı adı en az 3 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Ad Soyad TextField
                  TextFormField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Ad Soyad',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ad soyad boş bırakılamaz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Şifre TextField
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                         suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                      obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre boş bırakılamaz';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                        if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])').hasMatch(value)) {
                        return 'Şifre büyük, küçük harf ve rakam içermelidir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Kayıt Butonu
                  viewModel.isLoading
                    ? const Center(
                        child: SpinKitChasingDots(
                          color: Colors.cyan,
                          size: 50.0,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                           if (_formKey.currentState!.validate()) {
                            viewModel.signUp(
                              context,
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              fullNameController.text.trim(),
                               usernameController.text.trim(),
                            );
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  // Giriş Ekranına Yönlendirme
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      viewModel.navigateToLogin(context);
                    },
                    child: const Text('Zaten hesabınız var mı? Giriş Yapın'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}