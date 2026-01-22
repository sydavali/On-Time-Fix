import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'role_director.dart'; 

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    final AuthService authService = AuthService();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Show spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = authService.currentUser;
      if (user == null) {
        Navigator.of(context).pop(); 
        return;
      }

      WriteBatch batch = firestore.batch();

      final userDocRef = firestore.collection('users').doc(user.uid);
      batch.set(userDocRef, {
        'uid': user.uid,
        'email': user.email,
        'role': role,
        'createdAt': Timestamp.now(),
        'profileComplete': false,
      });

      if (role == 'technician') {
        final techDocRef = firestore.collection('technicians').doc(user.uid);
        batch.set(techDocRef, {
          'uid': user.uid, 
          'email': user.email,
          'profileComplete': false,
          'isAvailable': true,
          'isVerified': false,
          'rating': 0.0,
          'jobsCompleted': 0,
          'createdAt': Timestamp.now(),
        });
      }

      await batch.commit();

      if (context.mounted) {
        Navigator.of(context).pop(); // Hide spinner
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RoleDirector()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving role: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Role"),
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Who are you?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Choose your account type to get started.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // --- EXCELLENT UI: Expanded Cards ---
            Expanded(
              child: _PolishedRoleCard(
                icon: Icons.person_search_rounded,
                title: "Customer",
                subtitle: "I want to book a service",
                color: Colors.blue,
                onTap: () => _selectRole(context, 'customer'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _PolishedRoleCard(
                icon: Icons.handyman_rounded,
                title: "Technician",
                subtitle: "I want to find work",
                color: Colors.orange,
                onTap: () => _selectRole(context, 'technician'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- NEW POLISHED CARD WIDGET ---
class _PolishedRoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PolishedRoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}