import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText speech = SpeechToText();
  String transcribedText = '';
  bool _isListening = false;

  Future<void> _startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) => setState(() {}),
      onError: (error) => print("Error: $error"),
    );
    if (available) {
      setState(() {
        _isListening = true;
      });
      speech.listen(onResult: (result) {
        setState(() {
          transcribedText = result.recognizedWords;
        });
      });
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await speech.stop();
      setState(() {
        _isListening = false;
      });
    }
    _sendToServer(transcribedText);
  }

  Future<void> _sendToServer(String text) async {
    final url = Uri.parse('YOUR_API_ENDPOINT'); //Replace with your endpoint
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_KEY', //Replace with your API key
    };
    final body = jsonEncode({'text': text});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Transcription sent successfully!');
      } else {
        print('Error sending transcription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending transcription: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightGreen, Colors.red],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New Waypoint',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _isListening ? _stopListening() : _startListening();
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.lightGreen,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_off,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  //Handle SOS button press here
                  print("SOS pressed!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                child: Text('SOS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
