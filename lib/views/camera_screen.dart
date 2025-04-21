import 'dart:io';
import 'dart:async';
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
  DateTime? _lastProximitySoundTime;
  List<DetectedObject> detectedObjects = [];
  int _frameSkipCounter = 0;
  Timer? _frameRateTimer;
  bool _processingEnabled = true;
  
  // For proximity sounds
  int _proximityLevel = 0; // 0 = no obstacle, 1-3 = increasing proximity levels

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeObjectDetector();
    
    // Create a timer to control frame processing rate
    _frameRateTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      _processingEnabled = true;
    });
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    // Use medium resolution for better performance
    _controller = CameraController(cameras[0], ResolutionPreset.medium, 
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888);
    
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
      // Skip frames to improve performance
      if (_isDetecting || !_processingEnabled) return;
      
      _isDetecting = true;
      _processingEnabled = false; // Will be reset by timer

      try {
        // Get sensor orientation
        final sensorOrientation = _controller?.description.sensorOrientation ?? 0;
        // Pass sensor orientation to the conversion function
        final inputImage = await convertCameraImage(image, sensorOrientation);
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
    try {
      final objects = await objectDetector.processImage(inputImage);
      bool isThereAnObstacle = false;
      int numObstacles = 0;
      
      // Calculate obstacle proximity based on size and position
      int newProximityLevel = 0;
      double largestObstacleRatio = 0.0;
      
      if (objects.isNotEmpty) {
        for (var obj in objects) {
          final size = MediaQuery.of(context).size;
          if (isObstacle(obj, size.width.toInt(), size.height.toInt())) {
            isThereAnObstacle = true;
            numObstacles++;
            
            // Calculate object size ratio compared to screen (for proximity estimation)
            double objArea = obj.boundingBox.width * obj.boundingBox.height;
            double screenArea = size.width * size.height;
            double sizeRatio = objArea / screenArea;
            
            if (sizeRatio > largestObstacleRatio) {
              largestObstacleRatio = sizeRatio;
            }
          }
        }
        
        // Set proximity level based on the largest obstacle's size
        if (isThereAnObstacle) {
          if (largestObstacleRatio > 0.2) { // Very close
            newProximityLevel = 3;
          } else if (largestObstacleRatio > 0.1) { // Medium distance
            newProximityLevel = 2;
          } else { // Far but still in detection zone
            newProximityLevel = 1;
          }
          
          // Play TTS alert only occasionally
          DateTime now = DateTime.now();
          if (_lastAlertTime == null || now.difference(_lastAlertTime!).inSeconds >= 3) {
            _lastAlertTime = now;
            // Only use TTS on non-Android platforms or if proximity level is high
            if (!Platform.isAndroid || newProximityLevel == 3) {
              await flutterTts.speak("Obstacle detected.");
            }
          }
          
          // Play proximity sound on Android
          if (Platform.isAndroid) {
            _playProximitySound(newProximityLevel);
          }
        }
      }
      
      // Update the proximity level state
      _proximityLevel = isThereAnObstacle ? newProximityLevel : 0;
      
    } catch (e) {
      print("Error detecting objects: $e");
    }
  }
  
  void _playProximitySound(int level) async {
    DateTime now = DateTime.now();
    
    // Control sound frequency based on proximity level
    int cooldownMs;
    switch (level) {
      case 3: // Very close - rapid beeps
        cooldownMs = 400; 
        break;
      case 2: // Medium distance - medium frequency beeps
        cooldownMs = 800;
        break;
      case 1: // Far but detected - slow beeps
        cooldownMs = 1500;
        break;
      default:
        return; // No sound for level 0
    }
    
    // Check if enough time has passed since last sound
    if (_lastProximitySoundTime == null || 
        now.difference(_lastProximitySoundTime!).inMilliseconds >= cooldownMs) {
      _lastProximitySoundTime = now;
      
      // Use different sounds for different proximity levels
      String soundPath;
      switch (level) {
        case 3:
          soundPath = 'sounds/microphone/confirm.mp3'; // Higher pitch sound
          break;
        case 2:
          soundPath = 'sounds/microphone/refresh.mp3'; // Medium pitch sound
          break;
        case 1:
          soundPath = 'sounds/microphone/deactive_mic.mp3'; // Lower pitch sound
          break;
        default:
          return;
      }
      
      // Play at low volume (0.3 - 0.6 depending on proximity)
      double volume = 0.3 + (level * 0.1);
      await audioPlayer.setVolume(volume);
      await audioPlayer.play(AssetSource(soundPath));
    }
  }

  @override
  void dispose() {
    _objectDetector.close();
    _controller?.dispose();
    _frameRateTimer?.cancel(); // Cancel the timer when disposing
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
