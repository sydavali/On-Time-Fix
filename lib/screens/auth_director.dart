// lib/screens/auth_director.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'role_director.dart';
import 'login_screen.dart'; // <-- 1. ADD THIS IMPORT

class AuthDirector extends StatelessWidget {
  const AuthDirector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const RoleDirector(); 
          } else {
            return const LoginScreen(); // 2. (const is already removed, this is correct)
          }
        },
      ),
    );
  }
}