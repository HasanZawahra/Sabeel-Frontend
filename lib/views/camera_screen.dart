import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/utils/background_grdiant.dart';
import 'package:sabeel/utils/circular_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller?.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  bool currUser = AuthService.firebase().currentUser != null;

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: Container(
        decoration: backgroundGradient(),
        child: Column(
          children: [
          SizedBox(height: 32),
            // Destination progress bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.volume_up),
                      Text(
                        "Destination Progress",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(width: 24), // Spacer
                    ],
                  ),
                  LinearProgressIndicator(value: 0.75, minHeight: 8, color: Colors.green),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Camera Preview
            Expanded(
              child: _controller == null || !_controller!.value.isInitialized
                  ? Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CameraPreview(_controller!),
                    ),
            ),
        
        
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if(currUser) buildCircularButton(Icons.sos_rounded,  Color(0xFFB42A2A), () {},150),
                  if(currUser) SizedBox(width: 32),
                  buildCircularButton(Icons.mic,  const Color(0xFF85AB59),  () async {
                    Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
                  }, 150),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}
