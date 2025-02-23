import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sabeel/services/sos/constants.dart';
import 'package:sabeel/services/sos/whatsapp_functions.dart';
import 'package:sabeel/utils/background_grdiant.dart';
import 'package:sabeel/utils/circular_button.dart';

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({super.key});

  @override
  _VideoRecorderScreenState createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  CameraController? _controller;
  late List<CameraDescription> cameras;

  bool _isRecording = false;
  String? _videoPath;

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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print("Error starting video recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    try {
      final XFile file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = file.path;
      });
      // _sendToWhatsApp('+970595464739');
      if (_videoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No video recorded!")),
        );
      } else
        shareVideo(phoneNumber, _videoPath!, context, messageContent);
    } catch (e) {
      print("Error stopping video recording: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        body: Container(
            decoration: backgroundGradient(),
            child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      // appBar: AppBar(title: Text("Record & Send Video")),
      body: Container(
        decoration: backgroundGradient(),
        child: Column(
          children: [
            SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Expanded(
                child: _controller == null || !_controller!.value.isInitialized
                    ? Center(child: CircularProgressIndicator())
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CameraPreview(_controller!),
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCircularButton(_isRecording ? Icons.stop : Icons.videocam,
                 Colors.red, _isRecording ? _stopRecording : _startRecording,
                120)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
