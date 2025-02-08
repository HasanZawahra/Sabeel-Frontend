import 'package:flutter/material.dart';
import 'package:sabeel/constants/routes.dart';
import 'package:sabeel/services/auth/auth_exceptions.dart';
import 'package:sabeel/services/auth/auth_service.dart';
import 'package:sabeel/utils/show_error_dialog.dart';




class IdVerificationSecreen extends StatefulWidget {
  @override
  _IdVerificationSecreenState createState() => _IdVerificationSecreenState();
}

class _IdVerificationSecreenState extends State<IdVerificationSecreen> {
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
      appBar: AppBar(
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
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 70),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email Adress',
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                   ElevatedButton(
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
                    Navigator.pushNamedAndRemoveUntil(context, mapDownloadRoute , (route) => false);
                  
                  }
                  on UserNotFoundAuthException{
                    showErrorDialog(context, "User not found");
                  }
                  on WrongPasswordAuthException{
                    showErrorDialog(context, "Wrong password");
                  }
                  on InvalidEmailAuthException{
                    showErrorDialog(context, "Invalid email");
                  }
                  on GenericAuthException{
                    showErrorDialog(context, "An error occurred");
                  }
              }, 
                    child: Text("Sign In", style: TextStyle(color: Colors.white)),
                    
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: Text("Forgot password?", style: TextStyle(color: Colors.blue, fontSize: 18)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "OR",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, mapDownloadRoute);
                    },
                    child: Text("Sign In As a Geust", style: TextStyle(color: Colors.white)),

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
