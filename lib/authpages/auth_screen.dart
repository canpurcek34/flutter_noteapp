// authpages/AuthScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_noteapp/viewmodels/auth_screen_viewmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sistem UI ayarları (status bar ve navigation bar)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return ChangeNotifierProvider(
      create: (_) => AuthScreenViewModel(),
      child: _AuthScreenContent(),
    );
  }
}

class _AuthScreenContent extends StatefulWidget {
  @override
  _AuthScreenContentState createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends State<_AuthScreenContent>  with SingleTickerProviderStateMixin {
    late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
     _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
   @override
  Widget build(BuildContext context) {
      final viewModel = Provider.of<AuthScreenViewModel>(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animasyonlu Giriş Görseli
                  Center(
                    child: Lottie.asset(
                      'assets/auth_animation.json', // Lottie animasyon dosyası
                      width: 250,
                      height: 250,
                      controller: _animationController,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Başlık
                  Text(
                    'Hoş Geldiniz',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Alt Başlık
                  Text(
                    'Hesabınıza giriş yapın veya yeni bir hesap oluşturun.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Giriş Yap Butonu
                  _buildAuthButton(
                    context,
                    text: 'Giriş Yap',
                    icon: Icons.login_rounded,
                    onPressed: () => viewModel.navigateToLogin(context),
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  // Kayıt Ol Butonu
                  _buildAuthButton(
                    context,
                    text: 'Kaydol',
                    icon: Icons.person_add_rounded,
                    onPressed: () => viewModel.navigateToSignUp(context),
                    isPrimary: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

   Widget _buildAuthButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
          final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.5;
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
       width: buttonWidth,
        child: FilledButton.tonal(
           onPressed: onPressed,
           style: FilledButton.styleFrom(
           backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: isPrimary
              ? Theme.of(context).colorScheme.onPrimaryContainer
             : Theme.of(context).colorScheme.onSecondaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
           ),
         ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              Icon(icon),
           const SizedBox(width: 12),
            Text(
                  text,
                 style: const TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
               ),
             ),
           ],
         ),
        ),
     ),
   );
  }
}