import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_exceptions.dart';
import 'package:sabeel/services/auth/auth_service.dart';
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  border: Border.all(color: Colors.grey.shade300),
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
                          labelText: 'Email Address',
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
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
                    SizedBox(height: 24),
                    Semantics(
                      label: 'Sign In button',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 50),
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
                        child: Text("Sign In", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 8),
                    Semantics(
                      label: 'Forgot password button',
                      child: TextButton(
                        onPressed: () {},
                        child: Text("Forgot password?", style: TextStyle(color: Colors.blue, fontSize: 18)),
                      ),
                    ),
                    SizedBox(height: 8),
                    Semantics(
                      label: 'OR text',
                      child: Text(
                        "OR",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 16),
                    Semantics(
                      label: 'Sign In As a Guest button',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          context.push(mapDownloadRoute);
                        },
                        child: Text("Sign In As a Guest", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}