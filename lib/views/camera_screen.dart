import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/services/object_detection/detection_area.dart';
import 'package:sabeel/services/object_detection/functions.dart';
import 'package:sabeel/services/sos/constants.dart';
import 'package:sabeel/services/sos/whatsapp_functions.dart';
import 'package:sabeel/utils/background_grdiant.dart';
import 'package:sabeel/utils/buttons.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool currUser = AuthService.firebase().currentUser != null;
  CameraController? _controller;
  bool _isDetecting = false;
  late ObjectDetector _objectDetector;
  late List<CameraDescription> cameras;
  FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  DateTime? _lastAlertTime;
  List<DetectedObject> detectedObjects = [];
  

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeObjectDetector();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller?.initialize();
    if (_controller == null || !_controller!.value.isInitialized) {
      print("Camera not initialized, skipping detection");
      return;
    }
    if (mounted) {
      setState(() {
        _startDetection();
      });
    }
  }

  void _initializeObjectDetector() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: false,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<void> _startDetection() async {
    await _controller?.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final inputImage = await convertCameraImage(image);
        if (inputImage == null) {
          print("Warning: InputImage is null, skipping detection.");
          return;
        }
        await _detectObjects(inputImage, _objectDetector);
      } catch (e) {
        print("Error in image stream: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<void> _detectObjects(
      InputImage inputImage, ObjectDetector objectDetector) async {
    print("Processing image: ${inputImage.toString()}");

    try {
      final objects = await objectDetector.processImage(inputImage);
      bool isThereAnObstacle = false;
      int numObstacles = 0;
      if (objects.isNotEmpty) {
        for (var obj in objects) {
          final size = MediaQuery.of(context).size;
          if (isObstacle(obj, size.width.toInt(), size.height.toInt())) {
            isThereAnObstacle = true;
            numObstacles++;
            break;
          }
        }
        if (isThereAnObstacle) {
          print("Obstacles detected: $numObstacles");
          _alertUser();
        }
      }
      print("\n");
    } catch (e) {
      print("Error detecting objects: $e");
    }
  }

  void _alertUser() async {
    DateTime now = DateTime.now();

    if (_lastAlertTime == null ||
        now.difference(_lastAlertTime!).inSeconds >= 3) {
      _lastAlertTime = now;
      await flutterTts.speak("Obstacle detected.");
    }
  }

  @override
  void dispose() {
    _objectDetector.close();
    _controller?.dispose();
    super.dispose();
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
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        label: 'Destination Progress',
                        child: Text(
                          "Destination Progress",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 24), // Spacer
                    ],
                  ),
                  Semantics(
                    label: 'Progress bar',
                    value: '75% completed',
                    child: LinearProgressIndicator(
                        value: 0.75, minHeight: 8, color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Camera Preview
            Expanded(
              child: _controller == null || !_controller!.value.isInitialized
                  ? Center(child: Semantics(
                        label: 'Loading camera preview',
                        child: CircularProgressIndicator(),
                      ),)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Semantics(
                            label: 'Camera preview',
                            child: CameraPreview(_controller!), // Camera feed
                          ), // Camera feed
                          Positioned.fill(
                            child: CustomPaint(
                              painter: TrianglePainter(
                                imageWidth: MediaQuery.of(context).size.width,
                                imageHeight: MediaQuery.of(context).size.height,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (currUser)
                    Semantics(
                      label: 'SOS button',
                      child: buildCircularButton(Icons.sos_rounded,
                          Color(0xFFB42A2A), () {
                        if (!kIsWeb && Platform.isIOS) {
                          openWhatsAppChat(phoneNumber, messageContent);
                        } else {
                          context.push(videoRecorderRoute);
                        }
                      }, 120),
                    ),
                  if (currUser) SizedBox(width: 32),
                   Semantics(
                    label: 'Microphone button',
                    child: buildCircularButton(Icons.mic, const Color(0xFF85AB59),
                        () async {
                          await audioPlayer.play(AssetSource('sounds/microphone/active_mic.mp3'));
                      context.go(homeRoute);
                    }, 120),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
