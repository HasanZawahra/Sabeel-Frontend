import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:sabeel/constants/destinations.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/services/sos/constants.dart';
import 'package:sabeel/services/sos/whatsapp_functions.dart';
import 'package:sabeel/utils/background_grdiant.dart';
import 'package:sabeel/utils/buttons.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sabeel/utils/menu_action_dialog.dart';
import 'package:sabeel/utils/voise_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _speechEnabled = false;
  final player = AudioPlayer();
  SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  FlutterTts flutterTts = FlutterTts();
  bool _hasSpoken = false;
  String _lastSpokenPhrase = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    flutterTts.stop();
    super.dispose();
  }

  // This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    _speechEnabled = false;
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
  await _speechToText.listen(
    onResult: _onSpeechResult,
    // listenMode: ListenMode.dictation,
    // partialResults: false, // Avoid catching partial results
    onSoundLevelChange: (level) {
      if (level < 0.2) return; // Ignore very low sound levels
    },
  );
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
    String recognizedText = result.recognizedWords.toLowerCase();
      if (recognizedText != _lastSpokenPhrase) {
       setState(() {
      _lastWords = recognizedText;
      if( checkForDistination(_lastWords)){
        _lastWords+= ".\n\nplease confirm your destination by clicking the confirm button on the right bottom.";
      }
    });
  }
  }

  void _toggleLayout() async {
    setState(() {
      _speechEnabled = !_speechEnabled;
      if (_speechEnabled) {
        _startListening();
      } else {
        _stopListening();
        _lastWords = '';
        _hasSpoken = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDFFED5),
        elevation: 0,
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 0, 0, 0)),
        leading: AuthService.firebase().currentUser == null
            ? Semantics(
                label: 'Back',
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 35),
                  onPressed: () {
                    context.go(mapDownloadRoute);
                  },
                ),
              )
            : null,
        actions: [
          if (AuthService.firebase().currentUser != null)
            menuActionDialog(context),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        transitionBuilder: (widget, animation) {
          return FadeTransition(opacity: animation, child: widget);
        },
        child: _buildMainLayout(),
      ),
    );
  }

  Widget _buildMainLayout() {
    return Container(
      key: ValueKey(1),
      decoration: backgroundGradient(),
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: _speechEnabled
                ? Container(
                    key: ValueKey(1),
                    margin: EdgeInsets.all(20), // Add top margin
                    decoration: buildSlider(),
                    child: Stack(
                      children: [
                        VoiceActivityIndicator(),
                        Positioned(
                          top: MediaQuery.of(context).size.height / 5,
                          child: Container(
                            margin: EdgeInsets.all(20), // Add top margin
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.contain,
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.3),
                                
                                      child: Semantics(
                                        label:   _speechToText.isListening
                                              ? 'You said: $_lastWords'
                                              : 'Listening...',
                                        child: Text(
                                          _speechToText.isListening
                                              ? 'You said: $_lastWords'
                                              : 'Listening...',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: const Color.fromARGB(
                                                255, 13, 13, 13),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        Positioned(
                          bottom: MediaQuery.of(context).size.height / 35,
                          right: MediaQuery.of(context).size.width / 20,
                          child: Semantics(
                            label: 'Confirm button',
                            child: buildCircularButton(
                                Icons.check, const Color(0xFF85AB59), () {
                              player.play(
                                  AssetSource('sounds/microphone/confirm.mp3'));
                              context.push(cameraScreenRoute);
                            }, 130),
                          ),
                        ),
                        Positioned(
                          bottom: MediaQuery.of(context).size.height / 35,
                          left: MediaQuery.of(context).size.width / 20,
                          child: Semantics(
                            label: 'Refresh button',
                            child: buildCircularButton(Icons.refresh,
                                const Color.fromARGB(255, 180, 42, 42),
                                () async {
                              await player.play(
                                  AssetSource('sounds/microphone/refresh.mp3'));
                              refresh();
                            }, 130),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(key: ValueKey(2)),
          ),
          _buildTitle("New\nWaypoint"),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _speechEnabled
                ? MediaQuery.of(context).size.height / 20
                : MediaQuery.of(context).size.height / 4.5,
            left: _speechEnabled
                ? MediaQuery.of(context).size.width / 10
                : MediaQuery.of(context).size.width / 6.5,
            child: GestureDetector(
              onTap: _toggleLayout,
              child: Semantics(
                label: 'Microphone button',
                child: _buildMicButton(),
              ),
            ),
          ),
          AnimatedPositioned(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            top: MediaQuery.of(context).size.height / 1.77,
            left: _speechEnabled? -500 : MediaQuery.of(context).size.width / 20,
            child: Semantics(
                label: 'Destinations List button',
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9, 
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: buildRectangularButton(sayDestinationsList, Color.fromARGB(255, 106, 180, 42), 'Destinations List', 30),
                ),
              ),
          ),
          if (AuthService.firebase().currentUser != null)
            AnimatedPositioned(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 300),
              bottom: _speechEnabled ? -200 : 10,
              left: MediaQuery.of(context).size.width / 20,
              child: Semantics(
                label: 'SOS button',
                child: Container(
                  margin: EdgeInsets.only(bottom: 20), // Add bottom margin
                  width: MediaQuery.of(context).size.width *
                      0.9, // 75% of screen width
                  height: MediaQuery.of(context).size.height * 0.135,
                  child: buildRectangularButton(sos, const Color.fromARGB(248, 194, 13, 0), 'SOS', 75),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return Container(
      child: GestureDetector(
        onTap: () async {
          _toggleLayout();
          _speechEnabled
              ? await player
                  .play(AssetSource('sounds/microphone/active_mic.mp3'))
              : await player
                  .play(AssetSource('sounds/microphone/deactive_mic.mp3'));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _speechEnabled
              ? (MediaQuery.of(context).size.width / 1.4) / 2.73
              : MediaQuery.of(context).size.width / 1.4,
          height: _speechEnabled
              ? (MediaQuery.of(context).size.height / 3.2) / 2.73
              : MediaQuery.of(context).size.height / 3.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF85AB59),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Icon(_speechEnabled ? Icons.mic : Icons.mic_off,
              size:
                  _speechEnabled ? 80 : MediaQuery.of(context).size.width / 2.9,
              color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _speechEnabled ? -200 : MediaQuery.of(context).size.height / 50,
      left: MediaQuery.of(context).size.width / 20,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Semantics(
          label: 'Title: $title',
          child: Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              height: 0.8,
            ),
          ),
        ),
      ]),
    );
  }

  void refresh() {
    setState(() {
      _lastWords = '';
      _stopListening();
      Future.delayed(Duration(seconds: 1), () {
        _startListening();
      });
    });
  }

  bool checkForDistination(String text) {
    for (var dist in destinations) {
      if (text.toLowerCase().contains(dist)) {
        if (!_hasSpoken) {
          speak(dist);
          _hasSpoken = true;
        }
        return true;
      }
    }
    return false;
  }

  void speak(String text) async {
  _lastSpokenPhrase = text.toLowerCase();
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1);

  _stopListening(); // Stop listening before speaking

  await flutterTts.speak(
      "You Want to go to the $text building, please confirm by clicking the confirm button on the right bottom.");

  flutterTts.setCompletionHandler(() {
    Future.delayed(Duration(milliseconds: 200), () {
      _startListening(); // Resume listening after speech finishes
    });
  });

  Future.delayed(Duration(seconds: 5), () {
    _hasSpoken = false;
  });
}

void sayDestinationsList() async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1);

  await flutterTts.speak(
      "The available destinations are: ${destinations.join(', ')}");

  flutterTts.setCompletionHandler(() {
    Future.delayed(Duration(milliseconds: 200), () {
    });
  });
}

void sos() {
  if (!kIsWeb && Platform.isIOS) {
    openWhatsAppChat(phoneNumber, messageContent);
  } else
    context.push(videoRecorderRoute);
    }

}
