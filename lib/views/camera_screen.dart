import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/services/object_detection/tri.dart';
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
  final AudioPlayer audioPlayer = AudioPlayer();
  DateTime? _lastAlertTime;


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
    bool isObstacle = false;
    int numObstacles = 0;
    if (objects.isNotEmpty) {
      for (var obj in objects) {
        final size = MediaQuery.of(context).size;
        if (_isObstacle(obj, size.width.toInt(), size.height.toInt())) {
          isObstacle = true;
          numObstacles++;
          break;
        }
      }
    
      if(isObstacle){
      print("Obstacles detected: $numObstacles");   
         _alertUser();
        
    }
    
    }
    print("\n");

  } catch (e) {
    print("Error detecting objects: $e");
  }
}

  bool _isObstacle(DetectedObject obj, int w, int h) {
  final int imageWidth = w;
  final int imageHeight = h;

  final Point topPoint = Point(imageWidth/2.4, imageHeight*0.05);
  final Point bottomLeft = Point(imageWidth*0.1, imageHeight*0.65);
  final Point bottomRight = Point(imageWidth*0.8, imageHeight*0.65);

  // Get bounding box corners
  final Point topLeft = Point(obj.boundingBox.left, obj.boundingBox.top);
  final Point topRight = Point(obj.boundingBox.left + obj.boundingBox.width, obj.boundingBox.top);
  final Point bottomLeftBox = Point(obj.boundingBox.left, obj.boundingBox.top + obj.boundingBox.height);
  final Point bottomRightBox = Point(obj.boundingBox.left + obj.boundingBox.width, obj.boundingBox.top + obj.boundingBox.height);

  
  return _isPointInsideTriangle(topLeft, topPoint, bottomLeft, bottomRight) ||
         _isPointInsideTriangle(topRight, topPoint, bottomLeft, bottomRight) ||
         _isPointInsideTriangle(bottomLeftBox, topPoint, bottomLeft, bottomRight) ||
         _isPointInsideTriangle(bottomRightBox, topPoint, bottomLeft, bottomRight);
}


// Function to check if a point is inside a triangle using Barycentric coordinates
bool _isPointInsideTriangle(Point p, Point a, Point b, Point c) {
  num area = (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y);
  double s = ((a.y - c.y) * (p.x - c.x) + (c.x - a.x) * (p.y - c.y)) / area;
  double t = ((c.y - b.y) * (p.x - c.x) + (b.x - c.x) * (p.y - c.y)) / area;

  return s > 0 && t > 0 && (s + t) < 1;
}


  void _alertUser() async {
  DateTime now = DateTime.now();
  
  if (_lastAlertTime == null || now.difference(_lastAlertTime!).inSeconds >= 3) {
    _lastAlertTime = now; 
    audioPlayer.play(AssetSource("sounds/microphone/yell-stop-it-82603.mp3"));
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
                      child: Stack(
      children: [
        CameraPreview(_controller!), // Camera feed

        // Overlay for the detection zone
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