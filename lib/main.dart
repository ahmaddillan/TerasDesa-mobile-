import 'package:flutter/material.dart';
import 'package:terasdesa/login_page.dart';
import 'package:terasdesa/register_page.dart';
import 'package:terasdesa/homepage.dart';
import 'package:terasdesa/aset_page.dart';
import 'package:terasdesa/splash_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green).copyWith(
          primary: Colors.green[800]!,
          secondary: Colors.amber[700]!,
          surface: Colors.grey[100]!,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/homepage': (context) => const Homepage(),
        '/aset': (context) => const AsetPage(),
      },
    );
  }
}
