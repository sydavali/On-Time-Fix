// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart'; // <-- 1. ADD THIS IMPORT

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 2. THIS IS THE SEEDER FUNCTION
  Future<void> _seedDatabase(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('technicians');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final fakeTechnicians = [
      {'name': 'Ravi Kumar', 'service': 'Plumbing', 'rating': 4.5},
      {'name': 'Priya Sharma', 'service': 'Electrical', 'rating': 4.8},
      // ... (rest of the fake data) ...
    ];

    try {
      final batch = firestore.batch();
      for (var tech in fakeTechnicians) {
        final docRef = collection.doc();
        batch.set(docRef, {
          'uid': docRef.id,
          'name': tech['name'],
          'service': tech['service'],
          'rating': tech['rating'],
          'isAvailable': true,
          'createdAt': Timestamp.now(),
        });
      }
      await batch.commit();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Successfully seeded 15 technicians!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error seeding database: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                // --- 3. APPLY THE FIX HERE (ADD COMMA, ADD CONST) ---
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
                // ---------------------------------------------------
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to On Time Fix!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _seedDatabase(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('TEMPORARY: SEED DATABASE'),
            ),
            const SizedBox(height: 10),
            const Text(
              '(Press this only ONCE to add fake technicians)',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}