import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_exceptions.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/utils/background_grdiant.dart';
import 'package:sabeel/utils/error_dialog.dart';

class IdVerificationScreen extends StatefulWidget {
  @override
  _IdVerificationScreenState createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
            decoration: backgroundGradient(),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Semantics(
                  label: 'Enter Your Credentials title',
                  child: Text(
                    "Enter Your Credentials",
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 150, 148, 148)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Semantics(
                        label: 'Email Address input field',
                        child: TextField(
                          controller: _email,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email Address'          
                          ),
                          
                        ),
                      ),
                      SizedBox(height: 20),
                      Semantics(
                        label: 'Password input field',
                        child: TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Semantics(
                        label: 'Sign In button',
                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 35, 171, 250),
                            minimumSize: Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            try {
                              await AuthService.firebase().logIn(email: email, password: password);
                              context.go(mapDownloadRoute);
                            } on UserNotFoundAuthException {
                              showErrorDialog(context, "User not found");
                            } on WrongPasswordAuthException {
                              showErrorDialog(context, "Wrong password");
                            } on InvalidEmailAuthException {
                              showErrorDialog(context, "Invalid email");
                            } on GenericAuthException {
                              showErrorDialog(context, "An error occurred");
                            }
                          },
                          child: Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      SizedBox(height: 10),
                      Semantics(
                        label: 'Forgot password button',
                        child: TextButton(
                          onPressed: () {},
                          child: Text("Forgot password?", style: TextStyle(color: Colors.blue, fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 10),
                      Semantics(
                        label: 'OR',
                        child: Text(
                          "OR",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      SizedBox(height: 26),
                      Semantics(
                        label: 'Sign In As a Guest button',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            context.push(mapDownloadRoute);
                          },
                          child: Text("Sign In As a Guest", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}