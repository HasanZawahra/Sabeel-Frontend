import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For asset loading

class IdVerificationConfirmationScreen extends StatelessWidget {
  final File? capturedImage; // Allow null for web
  final String? webImageUrl; // URL for web image (if available)

  const IdVerificationConfirmationScreen({
    Key? key,
    this.capturedImage,
    this.webImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID-Verification'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'University ID Card',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please confirm that the card info is correct and proceed',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Conditional image display based on platform
              kIsWeb
                  ? webImageUrl != null
                      ? Image.network(
                          webImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text('Error loading image')),
                        )
                      : const Center(child: Text('No image available for web'))
                  : capturedImage != null
                      ? Image.file(
                          capturedImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text('Error loading image')),
                        )
                      : const Center(child: Text('No image available')),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Handle Continue - navigate to home screen
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle Continue - navigate to home screen
                  Navigator.pushNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
