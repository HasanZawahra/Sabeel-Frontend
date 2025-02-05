import 'package:flutter/material.dart';
import 'package:sabeel/constants/routes.dart';

class MapDownloadingProgress extends StatefulWidget {
  const MapDownloadingProgress({super.key});

  @override
  State<MapDownloadingProgress> createState() => _MapDownloadingProgressState();
}

class _MapDownloadingProgressState extends State<MapDownloadingProgress> {

bool _isProgressActive = true; 
double progress = 0.0;


void _startProgress() {
  if (progress < 1.0 && _isProgressActive) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_isProgressActive) {
        setState(() {
          progress += 0.01;
        });
        if (progress >= 1.0) {
          _isProgressActive = false;
          Navigator.pushNamed(context, homeRoute);
        } else {
          _startProgress();
        }
      }
    });
  }
}

@override
void initState() {
  super.initState();
  _startProgress();
}

@override
void dispose() {
  _isProgressActive = false;
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    _startProgress();
    return Scaffold(
      body:
       FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: 0.33, // Adjust this value to control the vertical position
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100),
            Text(
              "Downloading Map ...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.black,
                minHeight: 8,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "${(progress * 100).toInt()}% completed",
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
     
    );
  }
}