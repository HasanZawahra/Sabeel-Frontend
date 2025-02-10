
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
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height/20,
      right: MediaQuery.of(context).size.width/20,
      child: Container(
        width: 80,
        height: 40,
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height:  7.0 + _controller.value * 10,
              width: 7,
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
