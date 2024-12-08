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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthScreen(),
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen()
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobil ekran
      return MobileNotebookScreen();
    } else {
      // Masaüstü ekran
      return DesktopNotebookScreen();
    }
  }
}
