import 'dart:ui';

import 'package:flutter/material.dart';


class IdVerificationSecreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: 30,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Your Credentials",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Student Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onHover: (value) => {
                      ElevatedButton.styleFrom(
                        shadowColor:  Color.fromARGB(38, 69, 67, 67),
                        backgroundColor: Colors.grey.shade900,
                      ),
                    },
                    onPressed: () {},
                    child: Text("Sign In", style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: Text("Forgot password?", style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(60, 197, 197, 197),
                    minimumSize: Size(165, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                  ),
                  onPressed: () {},
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(165, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                  ),
                  onPressed: () {},
                  child: Text("Continue", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
