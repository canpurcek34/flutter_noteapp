// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/authpages/auth_screen.dart';
import 'package:flutter_noteapp/authpages/login_screen.dart';
import 'package:flutter_noteapp/authpages/sign_up_screen.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:flutter_noteapp/ui/home_screen.dart';
import 'package:provider/provider.dart';
import 'firebase/firebase_options.dart';
import 'package:flutter_noteapp/viewmodels/auth_viewmodel.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize locale data
  await initializeDateFormatting('tr_TR', null); // Add this line
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const NotebookApp(),
    ),
  );
}

class NotebookApp extends StatelessWidget {
  const NotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication',
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      home:  ChangeNotifierProvider(
            create: (_) => AuthViewModel(),
              child: _HandleAuth(),
          ),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen()
      },
    );
  }
}


class _HandleAuth extends StatelessWidget {
    @override
  Widget build(BuildContext context) {
      final authViewModel = Provider.of<AuthViewModel>(context);

     return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
             authViewModel.setAuthScreen();
           return  authViewModel.authScreen;
          } else if (user.email != null) {
           return const HomeScreen();
          } else {
             authViewModel.setAuthScreen();
            return authViewModel.authScreen;
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}