import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elmouaddibe_examen/auth/screens/signup_page.dart';
import 'package:elmouaddibe_examen/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/route_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  // Controllers for text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to validate and log in
  void validateAndLogin(BuildContext context) async {
    if (emailController.text.isEmpty || !emailController.text.contains("@")) {
      EasyLoading.showError("Please enter a valid email address");
      return;
    }
    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      EasyLoading.showError(
          "Please enter a valid password with at least 6 characters");
      return;
    }

    try {
      EasyLoading.show(status: 'Logging in...');

      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      User? user = userCredential.user;

      if (user != null) {
        EasyLoading.dismiss();
        EasyLoading.show(status: 'Fetching user informations...');
        // Fetch user details from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String name = userDoc['name'] ?? '';
          String photoUrl = userDoc['photo'] ?? '';

          EasyLoading.showSuccess('Welcome, $name!');

          await user.updateDisplayName(name);
          await user.updatePhotoURL(photoUrl);
          Get.offAll(() => const MyHomePage());
          // Optionally, you can navigate to another page or display the user's information
          // For example:
          // Navigator.pushReplacementNamed(context, '/home', arguments: {'name': name, 'photoUrl': photoUrl});
        } else {
          EasyLoading.showError('User data not found');
        }
      } else {
        EasyLoading.showError('Login failed');
      }
    } catch (e) {
      EasyLoading.showError('Invalid Email or Password');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/library.png'),
              const Text(
                'Sign In',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  validateAndLogin(
                      context); // Validate and login on button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Text("Login"),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Get.to(() => SignUpPage());
                },
                child: Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
