import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sabeel/services/sos/constants.dart';
import 'package:sabeel/services/sos/whatsapp_functions.dart';

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
        
      }
      else shareVideo(phoneNumber, _videoPath!, context, messageContent);

    } catch (e) {
      print("Error stopping video recording: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text("Record & Send Video")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Record & Send Video")),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_controller!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isRecording ? Icons.stop : Icons.videocam, size: 40, color: Colors.red),
                onPressed: _isRecording ? _stopRecording : _startRecording,
              ),
              SizedBox(width: 20),
              
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

}
