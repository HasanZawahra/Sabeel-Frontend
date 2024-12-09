import 'package:flutter/material.dart';
import 'package:sabeel/views/home_screen.dart';
import 'views/verification_screens/id_verification_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/idVerification': (context) => const IdVerificationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const IdVerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/splashscreen-en.gif'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNextScreen,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
