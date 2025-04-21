import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sabeel/services/navigation/routing_service.dart';
import 'firebase_options.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}

void main() async {
  try {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase with a try-catch to handle initialization errors
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Run the app
    runApp(const MyApp());
  } catch (e) {
    // Add error handling for debugging
    print('Error initializing app: $e');
    // Still attempt to run a minimal app for error reporting
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e', 
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    ));
  }
}