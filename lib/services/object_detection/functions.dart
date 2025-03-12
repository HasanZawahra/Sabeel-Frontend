import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

 Future<InputImage?> convertCameraImage(CameraImage image) async {
    try {
      if (Platform.isIOS) {
        print("Converting CameraImage to file for iOS...");
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/temp_image.jpg';

        // Convert CameraImage to JPEG
        final File imageFile =
            await convertCameraImageToFile(image, imagePath);

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
          format:
              InputImageFormat.nv21, // Ensure this matches your camera format
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
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

    final Point topPoint = Point(imageWidth / 2.4, imageHeight * 0.3);
    final Point bottomLeft = Point(imageWidth * 0.1, imageHeight * 0.60);
    final Point bottomRight = Point(imageWidth * 0.75, imageHeight * 0.60);

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

// checcking based on the intersection of the bounding box of the detected object with a triangle
//   bool _isObstacle(DetectedObject obj, int w, int h) {
  //   final int imageWidth = w;
  //   final int imageHeight = h;
  //   // Define the triangle vertices
  //   final Point topPoint = Point(imageWidth / 2.4, imageHeight * 0.4);
  //   final Point bottomLeft = Point(imageWidth * 0.1, imageHeight * 0.65);
  //   final Point bottomRight = Point(imageWidth * 0.75, imageHeight * 0.65);

  //   // Get bounding box corners
  //   final Point topLeft = Point(obj.boundingBox.left, obj.boundingBox.top);
  //   final Point topRight = Point(obj.boundingBox.left + obj.boundingBox.width, obj.boundingBox.top);
  //   final Point bottomLeftBox = Point(obj.boundingBox.left, obj.boundingBox.top + obj.boundingBox.height);
  //   final Point bottomRightBox = Point(obj.boundingBox.left + obj.boundingBox.width, obj.boundingBox.top + obj.boundingBox.height);

  //   // Define triangle edges
  //   List<List<Point>> triangleEdges = [
  //     [topPoint, bottomLeft],
  //     [bottomLeft, bottomRight],
  //     [bottomRight, topPoint]
  //   ];

  //   // Define bounding box edges
  //   List<List<Point>> boxEdges = [
  //     [topLeft, topRight],
  //     [topRight, bottomRightBox],
  //     [bottomRightBox, bottomLeftBox],
  //     [bottomLeftBox, topLeft]
  //   ];

  //   // Check if any bounding box edge intersects with any triangle edge
  //   for (var tEdge in triangleEdges) {
  //     for (var bEdge in boxEdges) {
  //       if (_doLinesIntersect(tEdge[0], tEdge[1], bEdge[0], bEdge[1])) {
  //         return true;
  //       }
  //     }
  //   }

  //   return false;
  // }

  // // Function to check if two line segments (p1-q1 and p2-q2) intersect
  // bool _doLinesIntersect(Point p1, Point q1, Point p2, Point q2) {
  //   int o1 = _orientation(p1, q1, p2);
  //   int o2 = _orientation(p1, q1, q2);
  //   int o3 = _orientation(p2, q2, p1);
  //   int o4 = _orientation(p2, q2, q1);

  //   // General case: If orientations are different, lines intersect
  //   if (o1 != o2 && o3 != o4) {
  //     return true;
  //   }

  //   return false;
  // }

  // // Function to find orientation of ordered triplet (p, q, r)
  // // Returns 0 (collinear), 1 (clockwise), or 2 (counterclockwise)
  // int _orientation(Point p, Point q, Point r) {
  //   num val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);

  //   if (val == 0) return 0; // Collinear
  //   return (val > 0) ? 1 : 2; // Clockwise or Counterclockwise
  // }