import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../utils/shared_prefrences_helper.dart';

class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student ID Verification')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null) Image.file(_image!),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text('Capture Student ID'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _image == null
                  ? null
                  : () async {
                      await SharedPreferencesHelper.setVerified(true);
                      Navigator.pop(context);
                    },
              child: const Text('Verify ID'),
            ),
          ],
        ),
      ),
    );
  }
}
