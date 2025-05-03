
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildCircularButton(IconData icon, Color color, VoidCallback onTap, double sizE) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Icon(icon, size: sizE, color: const Color.fromARGB(255, 255, 253, 253)),
      ),
    );
  }

  Widget buildRectangularButton(VoidCallback action, Color color, String text, int size) {
    return ElevatedButton(
                    onPressed: () {
                      action();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      // padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: GoogleFonts.roboto(
                        fontSize: size.toDouble(),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                      minimumSize: const Size(double.infinity, 60),
                      shadowColor: Colors.black.withOpacity(1),
                      elevation: 20,
                    ),
                    child: Text(text),
                  );
  }