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
    body: Semantics(
      label: 'Splash screen animation',
      hint: "Wait a moment until the app is ready",
      child: Image.asset(
        'assets/gifs/splashscreen-en.gif',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    ),
  );
}}



Future<void> navigateToIdVerificationAutomatically(BuildContext context) async {
    if(AuthService.firebase().currentUser != null) {
      context.go(mapDownloadRoute);
    }
    else  context.go(idVerificationRoute);
}