import 'package:flutter/material.dart';

import 'LoginScreen.dart';
import 'SignScreen.dart';
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null, // AppBar title kaldırıldı
        backgroundColor: Colors.transparent,
        elevation: 0, // Gölge kaldırıldı
      ),
      body: Center(
        // Öğeleri yatay ve dikey olarak ortalar
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçeriğin ortalanmasını sağlar
            children: [
              // Title
              const Text(
                'Hoş Geldiniz!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Description
              const Text(
                'Devam etmek için lütfen giriş yapın veya kaydolun.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              // Login Button
              ElevatedButton(
                onPressed: () {
                  // Giriş yap ekranına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Giriş Yap'),
              ),
              const SizedBox(height: 16),
              // Register Button
              ElevatedButton(
                onPressed: () {
                  // Giriş yap ekranına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Kaydol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
