import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/ui/DesktopNotebookScreen.dart';
import 'package:flutter_noteapp/ui/MobileNotebookScreen.dart';

import 'authpages/AuthScreen.dart';
import 'authpages/LoginScreen.dart';
import 'authpages/SignScreen.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(NotebookApp());
}

// ignore: must_be_immutable
class NotebookApp extends StatelessWidget {
  int screenWidth = 1;

  NotebookApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen()
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobil ekran
      return const MobileNotebookScreen();
    } else {
      // Masaüstü ekran
      return const DesktopNotebookScreen();
    }
  }
}
