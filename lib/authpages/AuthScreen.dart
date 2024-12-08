import 'package:flutter/material.dart';

import 'LoginScreen.dart';
import 'SignScreen.dart';
class AuthScreen extends StatelessWidget {
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
              Text(
                'Hoş Geldiniz!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Description
              Text(
                'Devam etmek için lütfen giriş yapın veya kaydolun.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              // Login Button
              ElevatedButton(
                onPressed: () {
                  // Giriş yap ekranına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Giriş Yap'),
              ),
              SizedBox(height: 16),
              // Register Button
              OutlinedButton(
                onPressed: () {
                  // Kayıt ekranına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Kaydol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
