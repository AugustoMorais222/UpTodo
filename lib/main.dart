import 'package:flutter/material.dart';
import 'package:uptodo/on_boarding_screen.dart';
import 'package:uptodo/splash_page.dart';
import 'package:uptodo/home_page.dart';
import 'home_page.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UpToDo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/on_boarding': (context) => OnboardingScreen(),
      },
    );
  }
}
