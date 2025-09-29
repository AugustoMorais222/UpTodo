import 'package:flutter/material.dart';
import 'color_utils.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '../assets/logo.png',
              width: 130,
              height: 130,
            ),
            const SizedBox(height: 50),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Colors.white),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
