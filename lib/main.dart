import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_noteapp/ui/HomeScreen.dart';
import 'authpages/AuthScreen.dart';
import 'authpages/LoginScreen.dart';
import 'authpages/SignScreen.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      theme: Provider.of<ThemeProvider>(context).currentTheme, // Tema providerdan sağlandı
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
