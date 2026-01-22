import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:on_time_fix/screens/edit_profile_screen.dart';
import 'package:on_time_fix/screens/customer/widgets/service_card.dart';
import 'package:on_time_fix/screens/customer/technician_list_screen.dart';
import 'package:on_time_fix/screens/login_screen.dart'; 
// 1. IMPORT YOUR NEW CENTRAL CONSTANTS FILE
import 'package:on_time_fix/shared/constants.dart';

// --- 2. THE ServiceCategory CLASS AND LIST ARE NOW REMOVED FROM HERE ---
// (We are importing them from constants.dart)

class BookServiceScreen extends StatelessWidget {
  const BookServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Service"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: "Edit Profile",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Welcome Header (Unchanged) ---
              const Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "What service do you need today?",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // --- Grid of Services (Unchanged, but now uses the imported list) ---
              GridView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.9, 
                ),
                itemCount: serviceCategories.length, // This now comes from constants.dart
                itemBuilder: (context, index) {
                  final category = serviceCategories[index]; // This now comes from constants.dart
                  return ServiceCard(
                    serviceName: category.name,
                    icon: category.icon,
                    color: category.color,
                    onTap: () {
                      _onCategoryTapped(context, category);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _onCategoryTapped(BuildContext context, ServiceCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TechnicianListScreen(
          category: category.name,
        ),
      ),
    );
  }
}