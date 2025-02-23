import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/services/sos/constants.dart';
import 'package:sabeel/services/sos/whatsapp_functions.dart';
import 'package:sabeel/utils/background_grdiant.dart';
import 'package:sabeel/utils/circular_button.dart';
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

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _speechToText.cancel();
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
    });
  }

  void _toggleLayout() async {
    setState(() {
      _speechEnabled = !_speechEnabled;
      if (_speechEnabled)
        _startListening();
      else {
        _stopListening();
        _lastWords = '';
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
            ? IconButton(
                icon: Icon(Icons.arrow_back, size: 35),
                onPressed: () {
                  context.go(mapDownloadRoute);
                },
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
                                  ),
                                ]),
                          ),
                        ),
                        Positioned(
                          bottom: MediaQuery.of(context).size.height / 35,
                          right: MediaQuery.of(context).size.width / 20,
                          child: buildCircularButton(
                              Icons.check, const Color(0xFF85AB59), () {
                            player.play(
                                AssetSource('sounds/microphone/confirm.mp3'));
                            context.push(cameraScreenRoute);
                          }, 130),
                        ),
                        Positioned(
                          bottom: MediaQuery.of(context).size.height / 35,
                          left: MediaQuery.of(context).size.width / 20,
                          child: buildCircularButton(Icons.refresh,
                              const Color.fromARGB(255, 180, 42, 42), () async {
                            await player.play(
                                AssetSource('sounds/microphone/refresh.mp3'));

                            setState(() {
                              _lastWords = '';
                            });
                          }, 130),
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
                : MediaQuery.of(context).size.height / 3.5,
            left: _speechEnabled
                ? MediaQuery.of(context).size.width / 10
                : MediaQuery.of(context).size.width / 6.5,
            child: GestureDetector(
              onTap: _toggleLayout,
              child: _buildMicButton(),
            ),
          ),
          if (AuthService.firebase().currentUser != null)
            AnimatedPositioned(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 300),
              bottom: _speechEnabled ? -200 : 10,
              left: MediaQuery.of(context).size.width / 20,
              child: Container(
                margin: EdgeInsets.only(bottom: 20), // Add bottom margin
                width: MediaQuery.of(context).size.width *
                    0.9, // 75% of screen width
                height: MediaQuery.of(context).size.height * 0.15,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!kIsWeb && Platform.isIOS) {
                      openWhatsAppChat(phoneNumber, messageContent);
                    } else
                      context.push(videoRecorderRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB42A2A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: GoogleFonts.roboto(
                      fontSize: 85,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                    minimumSize: const Size(double.infinity, 60),
                    shadowColor: Colors.black.withOpacity(1),
                    elevation: 20,
                  ),
                  child: const Text('SOS'),
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
                  .play(AssetSource('sounds/microphone/active_microphone.mp3'));
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
      top: _speechEnabled ? -200 : MediaQuery.of(context).size.height / 20,
      left: MediaQuery.of(context).size.width / 20,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: MediaQuery.of(context).size.width / 4.7,
            fontWeight: FontWeight.bold,
            height: 0.8,
          ),
        ),
      ]),
    );
  }
}
