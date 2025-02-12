import 'package:flutter/material.dart';

BoxDecoration backgroundGradient() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFDFFED5),
        Color.fromARGB(255, 195, 255, 173),
        Color.fromARGB(255, 255, 151, 151)
      ],
      stops: [0.0, 0.68, 1.0],
    ),
  );
}

BoxDecoration buildSlider() {
  return BoxDecoration(
    color: const Color.fromARGB(131, 255, 255, 255).withOpacity(0.5),
    borderRadius: BorderRadius.circular(20),
    
  );
}
