
import 'package:flutter/material.dart';

Widget buildCircularButton(IconData icon, Color color, VoidCallback onTap, double sizE) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Icon(icon, size: sizE, color: const Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }