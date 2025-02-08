import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
      home: const Main(),
      routes: {
        idVerificationRoute : (context) => IdVerificationSecreen(),
        homeRoute: (context) => const HomeScreen(),
        mapDownloadRoute: (context) => const MapDownloadScreen(),
        mapDownloadProgressRoute: (context) => const MapDownloadingProgress(),
      },
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {


  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToIdVerificationAutomatically(context);
    // });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/splashscreen-en.gif'),
        
      ),
    );
  }
  }

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const MyApp());
}


Future<void>_navigateToIdVerificationAutomatically(BuildContext context) async {
   await Future.delayed(const Duration(seconds: 5), () {
    Navigator.of(context).pushNamedAndRemoveUntil(idVerificationRoute, (route) => false);
  });
}