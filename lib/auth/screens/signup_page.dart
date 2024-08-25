import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elmouaddibe_examen/auth/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  File? selectedImage;
  TextEditingController fullName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void pickImageFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> signUpWithFile({
    required File file,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      EasyLoading.show(status: 'Creating Account...');
      // Initialize Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;

      // Generate a unique file name for the upload
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = storage.ref().child('user_photos/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Create a new user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // Open a document in Firestore using the userID
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Add user information to Firestore
        await userDoc.set({
          'name': name,
          'email': email,
          'photo': downloadURL,
        });

        // Optionally, update the user's display name and photo URL in Firebase Auth
        await user.updateDisplayName(name);
        await user.updatePhotoURL(downloadURL);
        EasyLoading.dismiss();
        EasyLoading.showToast('Account created. Pleasre login now',
            toastPosition: EasyLoadingToastPosition.bottom);
        Get.to(() => LoginPage());
      } else {
        EasyLoading.showError("Something went wrong. Please try again");
      }
    } catch (e) {
      EasyLoading.showError("Something went wrong. Please try again");
    }
  }

  void validateAndSignUp() {
    if (fullName.text.isEmpty) {
      showSnackBar("Please enter your full name");
      return;
    }
    if (email.text.isEmpty || !email.text.contains("@")) {
      showSnackBar("Please enter a valid email address");
      return;
    }
    if (password.text.isEmpty || password.text.length < 6) {
      showSnackBar("Please enter a password with at least 6 characters");
      return;
    }
    if (selectedImage == null) {
      showSnackBar("Please select a profile image");
      return;
    }

    // If all fields are valid, proceed with sign up
    signUpWithFile(
      name: fullName.text,
      file: selectedImage!,
      email: email.text,
      password: password.text,
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                pickImageFromGallery();
              },
              child: CircleAvatar(
                backgroundImage:
                    selectedImage == null ? null : FileImage(selectedImage!),
                radius: 50,
                backgroundColor: Colors.orangeAccent,
                child: selectedImage == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: fullName,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: email,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: validateAndSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                child: Text("Sign Up"),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.to(() => LoginPage());
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
