import 'package:elmouaddibe_examen/auth/screens/login_page.dart';
import 'package:elmouaddibe_examen/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return LoginPage();
        }
        return const MyHomePage();
      },
    );
  }
}
