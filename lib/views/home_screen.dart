import 'package:flutter/material.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/enums/menu_actions.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SpeechToText _speechToText = SpeechToText();
  // bool _speechEnabled = false;
  String _lastWords = '';

  // @override
  // void initState() {
  //   super.initState();
  //   _initSpeech();
  // }

  /// This has to happen only once per app
  // void _initSpeech() async {
  //   _speechEnabled = await _speechToText.initialize();
  //   setState(() {});
  // }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      debugPrint('Recognized words: $_lastWords');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEEFEE9),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: AuthService.firebase().currentUser == null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(mapDownloadRoute , (route) => false);
                },
                // iconSize: 35,
              )
            : null,
        actions: [ if(AuthService.firebase().currentUser != null) PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldUserLogOUt = await showLogoutDialog(context);
                if (shouldUserLogOUt) {
                  await AuthService.firebase().logOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(idVerificationRoute, (route) => false);
                }
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, child: Text("Log Out"))
            ];
          })],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEEFEE9), // 0%
              Color(0xFFCEF8BF), // 68%
              Color(0xFFF8B6B6), // 100%
            ],
            stops: [0.0, 0.68, 1.0], // Add stops for smoother gradient
          ),
        ),
        child: Stack(
          children: [
            Padding(
              // Added padding for better alignment
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft, // Align to top-left
                child: Container(
                  margin: EdgeInsets.only(top: 75), // Add top margin
                  child: Text(
                    'New Waypoint',
                    style: GoogleFonts.roboto(
                      // Use Roboto font
                      fontSize: 85,
                      fontWeight: FontWeight.bold,
                      height: 0.8, // Reduce line height
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20), // Added space for better layout
                  GestureDetector(
                    onTap: () {
                      _speechToText.isNotListening
                          ? _startListening()
                          : _stopListening();
                    },
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF85AB59),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 17,
                              offset:
                                  Offset(0, 22), // changes position of shadow
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 250,
                          backgroundColor: Colors.transparent,
                          child: Transform.scale(
                            scaleY: 1.2, // Scale the shape to make it more oval
                            child: Icon(
                              _speechToText.isNotListening
                                  ? Icons.mic_off
                                  : Icons.mic,
                              size: 200,
                              color: Colors.black
                                  .withOpacity(0.7), // Make the icon less black
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.2),
                                  offset: Offset(5.0, 5.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(AuthService.firebase().currentUser != null)
        Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 20), // Add bottom margin
                width: MediaQuery.of(context).size.width *
                    0.9, // 75% of screen width
                height: 120,
                child: ElevatedButton(
                  onPressed: () {
                    //Handle SOS button press here
                    debugPrint("SOS pressed!");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB42A2A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Make the button boxy
                    ),
                    textStyle: GoogleFonts.roboto(
                      fontSize: 85,
                      fontWeight: FontWeight.w900, // Bolder text
                      letterSpacing: 2.0, // More letter spacing
                    ),
                    minimumSize: const Size(double.infinity, 60),
                    shadowColor: Colors.black.withOpacity(0.6),
                    elevation: 20,
                  ),
                  child: const Text('SOS'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("Cansel")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("Log out")),
          ],
        );
      }).then((value) => value ?? false);
}