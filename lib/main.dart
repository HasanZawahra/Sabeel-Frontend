import 'package:flutter/material.dart';
import 'package:sabeel/views/home_screen.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/views/id_verification_secreen.dart';
import 'package:sabeel/views/map_download_screen.dart';
import 'package:sabeel/views/map_downloading_progress_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        splashRoute : (context) => const SplashScreen(),
        idVerificationRoute : (context) => IdVerificationSecreen(),
        homeRoute: (context) => const HomeScreen(),
        mapDownloadRoute: (context) => const MapDownloadScreen(),
        mapDownloadProgressRoute: (context) => const MapDownloadingProgress(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/splashscreen-en.gif'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, idVerificationRoute);
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
