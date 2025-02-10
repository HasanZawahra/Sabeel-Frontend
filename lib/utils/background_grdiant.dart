import 'package:flutter/material.dart';

BoxDecoration backgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEEFEE9), Color(0xFFCEF8BF), Color(0xFFF8B6B6)],
        stops: [0.0, 0.68, 1.0],
      ),
    );
  }