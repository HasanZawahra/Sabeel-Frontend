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
import 'package:sabeel/views/home_screen/voise_indicator.dart';

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
        backgroundColor: Color(0xFFDFFED5),
        elevation: 0,
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 0, 0, 0)),
        leading: AuthService.firebase().currentUser == null
        ? IconButton(
            icon: Icon(Icons.arrow_back, size: 35),
            onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              mapDownloadRoute, (route) => false);
            },
          )
        : null,
        
        actions: [
          if (AuthService.firebase().currentUser != null)
        PopupMenuButton<MenuAction>(
          icon: Icon(Icons.menu, size: 35,), // Change the icon to a burger menu
          onSelected: (value) async {
            switch (value) {
          case MenuAction.logout:
            final shouldUserLogOUt = await showLogoutDialog(context);
            if (shouldUserLogOUt) {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
              idVerificationRoute, (route) => false);
            }
            break;
            }
          },
          itemBuilder: (context) {
            return const [
          PopupMenuItem<MenuAction>(
              value: MenuAction.logout, child: Text("Log Out"))
            ];
          },
        )
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
          child: _showNewLayout
              ? Container(
            key: ValueKey(1),
            margin: EdgeInsets.all(20), // Add top margin
            decoration: buildSlider(),
            child: Stack(
              children: [
                VoiceActivityIndicator(),
                Positioned(
            bottom: MediaQuery.of(context).size.height / 35,
            right: MediaQuery.of(context).size.width / 20,
            child: _buildCircularButton(Icons.refresh, const Color(0xFF85AB59), () {}),
                ),
                Positioned(
            bottom: MediaQuery.of(context).size.height / 35,
            left: MediaQuery.of(context).size.width / 20,
            child: _buildCircularButton(Icons.arrow_back, const Color.fromARGB(255, 180, 42, 42), () {}),
                ),
   
      // )
              ],
            ),
          )
              : Container(key: ValueKey(2)),
        )
                ,
                _buildTitle("New Waypoint"),
            _buildTitle("New Waypoint"),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showNewLayout ? 40 : MediaQuery.of(context).size.height / 4,
              left: _showNewLayout ? 40 : MediaQuery.of(context).size.width / 6.5,
              child: GestureDetector(
                onTap: _toggleLayout,
                child: _buildMicButton(),
              ),
            ),
            if (AuthService.firebase().currentUser != null)
              AnimatedPositioned(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 300),
                bottom: _showNewLayout ? -200 : 0,
                left: MediaQuery.of(context).size.width / 20,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20), // Add bottom margin
                  width: MediaQuery.of(context).size.width *
                      0.9, // 75% of screen width
                  height: MediaQuery.of(context).size.height * 0.15,
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
                            BorderRadius.circular(20),
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
          final player = AudioPlayer();
          _showNewLayout
              ? await player
                  .play(AssetSource('sounds/microphone/active_microphone.mp3'))
              : await player.play(
                  AssetSource('sounds/microphone/inactive_microphone.mp3'));
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
          child: Icon(_showNewLayout ? Icons.mic : Icons.mic_off,
              size: _showNewLayout ? 80 : 150, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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

 Widget _buildCircularButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Icon(icon, size: 100, color: const Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }