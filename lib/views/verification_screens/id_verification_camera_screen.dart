import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'id_verification_confirmation_screen.dart';

class IdVerificationCameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const IdVerificationCameraScreen({Key? key, required this.camera})
      : super(key: key);

  @override
  State<IdVerificationCameraScreen> createState() =>
      _IdVerificationCameraScreenState();
}

class _IdVerificationCameraScreenState
    extends State<IdVerificationCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    await _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      if (kIsWeb) {
        final webImageURL = image.path; // Assuming the path is a URL for web
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                IdVerificationConfirmationScreen(webImageUrl: webImageURL),
          ),
        );
      } else {
        final capturedImage = File(image.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                IdVerificationConfirmationScreen(capturedImage: capturedImage),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: const Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
                // Title and Instructions
                const Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        'ID Card Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Please point the camera at the ID card. Position it inside the frame. Make sure it is clear enough.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Camera Controls
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: _takePicture,
                        child: Icon(Icons.camera_alt),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
