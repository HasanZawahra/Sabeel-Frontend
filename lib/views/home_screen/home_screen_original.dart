import 'package:flutter/material.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/enums/menu_actions.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/utils/background_grdiant.dart';
import 'package:sabeel/utils/logout_dialog.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNewLayout = false; // Track the layout change

  // SpeechToText _speechToText = SpeechToText();
  // bool _speechEnabled = false;
  // String _lastWords = '';

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
  // void _startListening() async {
  //   await _speechToText.listen(onResult: _onSpeechResult);
  //   setState(() {});
  // }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  // void _stopListening() async {
  //   await _speechToText.stop();
  //   setState(() {});
  // }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   setState(() {
  //     _lastWords = result.recognizedWords;
  //     debugPrint('Recognized words: $_lastWords');
  //   });
  // }

  void _toggleLayout() {
    setState(() {
      _showNewLayout = !_showNewLayout;
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
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        transitionBuilder: (widget, animation) {
          return FadeTransition(opacity: animation, child: widget);
        },
        child: 
             _buildMainLayout(),
        // _showNewLayout
        //     ? NewLayout(onBack: _toggleLayout)
        //     :
      ),
    );
  }

  Widget _buildMainLayout() {
    return Container(
      key: ValueKey(1),
      decoration: backgroundGradient(),
      child: Stack(
        children: [
          _buildTitle("New Waypoint"),
          AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showNewLayout ? 20 : MediaQuery.of(context).size.height / 4,
              left: _showNewLayout ? 30 :MediaQuery.of(context).size.width /6.5 ,
            child: GestureDetector(
              onTap: _toggleLayout, // Toggle layout on tap
              child: _buildMicButton(),
            ),
          ),
          if(AuthService.firebase().currentUser != null)

          AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _showNewLayout ? -200 : 0,
              left: MediaQuery.of(context).size.width / 20,
             
              child: Container(
                margin: EdgeInsets.only(bottom: 20), // Add bottom margin
                width: MediaQuery.of(context).size.width *
                    0.9, // 75% of screen width
                height: MediaQuery.of(context).size.height *
                    0.15,
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
                          BorderRadius.circular(20), // Make the button boxy
                    ),
                    textStyle: GoogleFonts.roboto(
                      fontSize: 85,
                      fontWeight: FontWeight.w900, // Bolder text
                      letterSpacing: 2.0, // More letter spacing
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
    return  Container(
              child: GestureDetector(
                onTap: () async {
          _toggleLayout();
          final player = AudioPlayer();
          await player.play(AssetSource('sounds/microphone/active_microphone.mp3'));
        },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _showNewLayout ? 110 : 300,
                  height: _showNewLayout ? 110 : 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF85AB59),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: 
                  Icon( _showNewLayout ? Icons.mic
                                      : Icons.mic_off, size: _showNewLayout ? 80 : 150, color: Colors.black87),
                  
              
              ),
            ),
    );
  }

  Widget _buildTitle(String title) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: _showNewLayout ? -200 : 22.0,
      left: 20,
      child: Align(
          child: Container(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'New\nWaypoint',
                style: GoogleFonts.roboto(
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                  height: 0.8,
                ),
              ),
            ),
          ),
        ),
      
    );
  }
    // Padding(
    //           // Added padding for better alignment
            //   padding: const EdgeInsets.all(22.0),
            //   child: Align(
            //     alignment: Alignment.topLeft, // Align to top-left
            //     child: Container(
            //       margin: EdgeInsets.only(top: 20), // Add top margin
            //       child: Text(
            //         'New Waypoint',
            //         style: GoogleFonts.roboto(
            //           // Use Roboto font
            //           fontSize: 90,
            //           fontWeight: FontWeight.bold,
            //           height: 0.8, // Reduce line height
            //         ),
            //       ),
            //     ),
            //   ),
            // );
  }


