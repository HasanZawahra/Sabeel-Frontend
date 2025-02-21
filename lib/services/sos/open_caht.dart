import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'dart:io';
import 'package:share/share.dart' as share;
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';
import 'dart:io';


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
      print('Video recorded to: ${file.path}');
      setState(() {
        _isRecording = false;
        _videoPath = file.path;
      });
      // _sendToWhatsApp('+970595464739');
      _shareVideo('+970595464739');
    } catch (e) {
      print("Error stopping video recording: $e");
    }
  }

Future<void> _shareVideo(String phoneNumber) async {
  if (_videoPath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No video recorded!")),
    );
    return;
  }

  try {
    final file = File(_videoPath!);
    
    if (await file.exists()) {
      if (Platform.isIOS) {
        // On iOS, show the Share Sheet so the user can pick WhatsApp manually
        await share_plus.Share.shareXFiles(
          [XFile(_videoPath!)],
          text: "I think I lost my way in the campus, please check this video to identify my location.",
        );
      } else {
        // On Android, open WhatsApp chat and then send the file
        final Uri uri = Uri.parse("whatsapp://send?phone=$phoneNumber&text=I think I lost my way in the campus, please check this video to identify my location.");

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          await Future.delayed(Duration(seconds: 2)); // Wait for chat to open

          await WhatsappShare.shareFile(
            phone: phoneNumber,
            filePath: [_videoPath!],
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("WhatsApp is not installed!")),
          );
        }
      }
    } else {
      print("Video file not found!");
    }
  } catch (e) {
    print("Error sharing video: $e");
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
