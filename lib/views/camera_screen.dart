import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/services/sos/constants.dart';
import 'package:sabeel/services/sos/whatsapp_functions.dart';
import 'package:sabeel/utils/background_grdiant.dart';
import 'package:sabeel/utils/circular_button.dart';
import 'package:image/image.dart' as img;

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
       final inputImage = await _convertCameraImage(image);
       if (inputImage == null) {
         print("Warning: InputImage is null, skipping detection.");
         return;
       }
       await _detectObjects(inputImage);
     } catch (e) {
       print("Error in image stream: $e");
     } finally {
       _isDetecting = false;
     }
   });
}


  Future<InputImage?> _convertCameraImage(CameraImage image) async {
  try {
      if (Platform.isIOS) {
        print("Converting CameraImage to file for iOS...");
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/temp_image.jpg';

        // Convert CameraImage to JPEG
        final File imageFile = await _convertCameraImageToFile(image, imagePath);
        
        if (await imageFile.exists()) {
          print("Image successfully saved at: $imagePath");
          return InputImage.fromFilePath(imagePath);
        } else {
          print("Error: Image file not found at $imagePath");
          return null;
        }
      }

      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21, // Ensure this matches your camera format
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
  } catch (e) {
    print("Error creating InputImage: $e");
    return null;
  }
}

Future<File> _convertCameraImageToFile(CameraImage image, String path) async {
  try {
    // Convert CameraImage to an Image package format
    img.Image convertedImage = img.Image.fromBytes(
        image.width,
        image.height,
        image.planes[0].bytes,
      );

    // Encode image to JPEG
    List<int> jpegBytes = img.encodeJpg(convertedImage);
    File file = File(path);
    await file.writeAsBytes(Uint8List.fromList(jpegBytes));

    return file;
  } catch (e) {
    print("Error converting CameraImage to file: $e");
    return File('');
  }
}


  Future<void> _detectObjects(InputImage inputImage) async {
  print("Processing image: ${inputImage.toString()}");

  try {
    final objects = await _objectDetector.processImage(inputImage);
    int numObsticles = 0;

    if (objects.isNotEmpty) {
      for (var obj in objects) {
        if (_isObstacle(obj)) {
          print("");
          numObsticles++;
          _alertUser();
          break;
        }
      }
    print("Detected objects: ${numObsticles}");
    }

  } catch (e) {
    print("Error detecting objects: $e");
  }
}

  bool _isObstacle(DetectedObject obj) {
  final double imageWidth = 640;  // Adjust based on actual image width
  final double imageHeight = 480; // Adjust based on actual image height

  // Define the triangle (assuming a symmetrical triangle in the center)
  final img.Point topPoint = img.Point(imageWidth / 2, imageHeight * 0.3); // Peak of the triangle
  final img.Point bottomLeft = img.Point(imageWidth * 0.2, imageHeight * 0.9);
  final img.Point bottomRight = img.Point(imageWidth * 0.8, imageHeight * 0.9);

  // Convert bounding box center to a point
  final double centerX = obj.boundingBox.left + (obj.boundingBox.width / 2);
  final double centerY = obj.boundingBox.top + (obj.boundingBox.height / 2);
  final img.Point objectCenter = img.Point(centerX, centerY);


  // Check if object is inside the triangular region
  return _isPointInsideTriangle(objectCenter, topPoint, bottomLeft, bottomRight);
}

// Function to check if a point is inside a triangle using Barycentric coordinates
bool _isPointInsideTriangle(img.Point p, img.Point a, img.Point b, img.Point c) {
  num area = (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y);
  double s = ((a.y - c.y) * (p.x - c.x) + (c.x - a.x) * (p.y - c.y)) / area;
  double t = ((c.y - b.y) * (p.x - c.x) + (b.x - c.x) * (p.y - c.y)) / area;

  return s > 0 && t > 0 && (s + t) < 1;
}

  void _alertUser() async {
    await flutterTts.speak("Obstacle detected ahead");
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
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                  if (currUser)
                    buildCircularButton(Icons.sos_rounded, Color(0xFFB42A2A), () {
                      if (!kIsWeb && Platform.isIOS) {
                        openWhatsAppChat(phoneNumber, messageContent);
                      } else {
                        context.push(videoRecorderRoute);
                      }
                    }, 120),
                  if (currUser) SizedBox(width: 32),
                  buildCircularButton(Icons.mic, const Color(0xFF85AB59), () async {
                    context.go(homeRoute);
                  }, 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}