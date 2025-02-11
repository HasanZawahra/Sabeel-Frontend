import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'firebase_options.dart';
import 'package:sabeel/views/home_screen/home_screen_original.dart';
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
    //   navigateToIdVerificationAutomatically(context);
    // });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/gifs/splashscreen-en.gif'),
        
      ),
      appBar:AppBar( leading:  IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(idVerificationRoute , (route) => false);
                },))
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


Future<void> navigateToIdVerificationAutomatically(BuildContext context) async {
   await Future.delayed(const Duration(seconds: 5), () {
    if(AuthService.firebase().currentUser != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
    }
else  Navigator.of(context).pushNamedAndRemoveUntil(idVerificationRoute, (route) => false);
  });
}