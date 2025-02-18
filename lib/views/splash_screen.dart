import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        navigateToIdVerificationAutomatically(context);
      }
    });
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/gifs/splashscreen-en.gif'),
      ),
    );
  }
}




Future<void> navigateToIdVerificationAutomatically(BuildContext context) async {
    if(AuthService.firebase().currentUser != null) {
      context.go(mapDownloadRoute);
    }
    else  context.go(idVerificationRoute);
}