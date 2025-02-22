import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';

Future<void> openWhatsAppChat(String phoneNumber, String message) async {
  final Uri url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.parse(message)}');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}


Future<void> shareVideo(String phoneNumber, String videoPath, BuildContext context, String message) async {
  
  try {
    final file = File(videoPath);
    
    if (await file.exists()) {

      final Uri uri = Uri.parse("whatsapp://send?phone=$phoneNumber&text=${Uri.parse(message)}");


        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          await Future.delayed(Duration(seconds: 2)); // Wait for chat to open

          await WhatsappShare.shareFile(
            phone: phoneNumber,
            filePath: [videoPath],
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("WhatsApp is not installed!")),
          );
        }
      
    } else {
      print("Video file not found!");
    }
  } catch (e) {
    print("Error sharing video: $e");
  }
}