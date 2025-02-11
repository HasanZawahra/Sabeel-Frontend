
import 'package:flutter/material.dart';

class VoiceActivityIndicator extends StatefulWidget {
  @override
  _VoiceActivityIndicatorState createState() => _VoiceActivityIndicatorState();
}

class _VoiceActivityIndicatorState extends State<VoiceActivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.value = 0;
    super.dispose();
  }

  void updateVoiceInput(double voiceLevel) {
    setState(() {
      _controller.value = voiceLevel;
    });
  }

  void resetVoiceInput() {
  setState(() {
    _controller.value = 0;
  });
}

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height/18,
      right: MediaQuery.of(context).size.width/10,
      child: Container(
        
        width: 120,
        height: 60,
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(9, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 100),
              height:  7 + (!index.isEven? _controller.value * 60 : _controller.value * 30),
              width: 6,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 89, 89, 89),
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
        ),
      ),
    );
  }
}
