import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // Added import for WriteBuffer
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// Accepts sensorOrientation (in degrees) to determine the correct rotation for Android
Future<InputImage?> convertCameraImage(CameraImage image, int sensorOrientation) async {
  try {
    if (Platform.isIOS) {
      print("Converting CameraImage to file for iOS...");
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/temp_image.jpg';

      // Convert CameraImage to JPEG
      final File imageFile = await convertCameraImageToFile(image, imagePath);

      if (await imageFile.exists()) {
        print("Image successfully saved at: $imagePath");
        return InputImage.fromFilePath(imagePath);
      } else {
        print("Error: Image file not found at $imagePath");
        return null;
      }
    } else if (Platform.isAndroid) {
      // Combine planes for NV21 format
      final allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      // Determine the correct rotation based on camera sensor orientation
      InputImageRotation imageRotation;
      switch (sensorOrientation) {
        case 90:
          imageRotation = InputImageRotation.rotation90deg;
          break;
        case 180:
          imageRotation = InputImageRotation.rotation180deg;
          break;
        case 270:
          imageRotation = InputImageRotation.rotation270deg;
          break;
        case 0:
        default:
          imageRotation = InputImageRotation.rotation0deg;
          break;
      }

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation, // Use calculated rotation
        format: InputImageFormat.nv21, // Corresponds to ImageFormatGroup.yuv420
        bytesPerRow: image.planes[0].bytesPerRow, // Y plane stride
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
    } else {
      print("Unsupported platform for convertCameraImage");
      return null;
    }
  } catch (e) {
    print("Error creating InputImage: $e");
    return null;
  }
}

Future<File> convertCameraImageToFile(CameraImage image, String path) async {
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

bool isObstacle(DetectedObject obj, int w, int h) {
  final int imageWidth = w;
  final int imageHeight = h;

  // Centered triangle points
  final Point topPoint = Point(imageWidth / 2, imageHeight * 0.3); // Centered X
  final Point bottomLeft = Point(imageWidth * 0.1, imageHeight * 0.60); // Symmetrical X
  final Point bottomRight = Point(imageWidth * 0.9, imageHeight * 0.60); // Symmetrical X

  // Get bounding box corners
  final Point topLeft = Point(obj.boundingBox.left, obj.boundingBox.top);
  final Point topRight = Point(obj.boundingBox.left + obj.boundingBox.width, obj.boundingBox.top);
  final Point bottomLeftBox = Point(obj.boundingBox.left, obj.boundingBox.top + obj.boundingBox.height);
  final Point bottomRightBox = Point(obj.boundingBox.left + obj.boundingBox.width, obj.boundingBox.top + obj.boundingBox.height);

  return isPointInsideTriangle(topLeft, topPoint, bottomLeft, bottomRight) ||
         isPointInsideTriangle(topRight, topPoint, bottomLeft, bottomRight) ||
         isPointInsideTriangle(bottomLeftBox, topPoint, bottomLeft, bottomRight) ||
         isPointInsideTriangle(bottomRightBox, topPoint, bottomLeft, bottomRight);
}

bool isPointInsideTriangle(Point p, Point a, Point b, Point c) {
  num area = (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y);
  double s = ((a.y - c.y) * (p.x - c.x) + (c.x - a.x) * (p.y - c.y)) / area;
  double t = ((c.y - b.y) * (p.x - c.x) + (b.x - c.x) * (p.y - c.y)) / area;

  return s > 0 && t > 0 && (s + t) < 1;
}