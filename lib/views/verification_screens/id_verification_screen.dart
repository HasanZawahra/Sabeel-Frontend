import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'id_verification_camera_screen.dart';

class IdVerificationScreen extends StatelessWidget {
  const IdVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20), // Added spacing for better visual
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Let\'s verify your identity',
                        style: GoogleFonts.roboto(
                          fontSize: 38,
                          fontWeight: FontWeight.w900, // Made it bolder
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We are required to verify your identity before you can use the application. Your information will be encrypted and stored securely.',
                        style: GoogleFonts.roboto(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildIdCard(), // Using a custom widget for the ID card
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Added spacing
                ElevatedButton(
                  onPressed: () async {
                    // Obtain a list of the available cameras on the device.
                    final cameras = await availableCameras();
                    // Get a specific camera from the list of available cameras.
                    final firstCamera = cameras.first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            IdVerificationCameraScreen(camera: firstCamera),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Match the button color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white, // Set text color to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          4), // Less border radius for a boxy look
                    ),
                  ),
                  child: Text(
                    'Verify Identity',
                    style: GoogleFonts.roboto(fontSize: 18),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(height: 10), // Added spacing
                TextButton(
                  onPressed: () {
                    // Handle guest sign-in
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signing in as guest...')),
                    );
                  },
                  child: Text(
                    'Sign-In As A Guest',
                    style: GoogleFonts.roboto(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCard() {
    return Center(
      child: Image.asset(
        'assets/idpng.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
