// lib/screens/role_director.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'customer/create_customer_profile_screen.dart';
import 'technician/create_technician_profile_screen.dart';
import 'technician/pending_approval_screen.dart';

import 'customer_main_nav.dart'; 
import 'technician_home_screen.dart';
import 'login_screen.dart'; 

class RoleDirector extends StatefulWidget {
  const RoleDirector({super.key});

  @override
  State<RoleDirector> createState() => _RoleDirectorState();
}

class _RoleDirectorState extends State<RoleDirector> {
  
  late Stream<DocumentSnapshot> _userStream;
  
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _userStream = FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if (user == null) {
      return const LoginScreen(); 
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream, 
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = data['role'];
          
          final bool profileComplete = data['profileComplete'] ?? true; 

          if (!profileComplete) {
            if (role == 'customer') {
              return const CreateCustomerProfileScreen();
            } else if (role == 'technician') {
              return const CreateTechnicianProfileScreen();
            }
          }
          
          if (role == 'customer') {
            return const CustomerMainNavigation();
          } else if (role == 'technician') {
            
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('technicians').doc(user!.uid).snapshots(),
              builder: (context, techSnapshot) {
                if (techSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                if (!techSnapshot.hasData || !techSnapshot.data!.exists) {
                  return const CreateTechnicianProfileScreen();
                }

                final techData = techSnapshot.data!.data() as Map<String, dynamic>;
                
                final bool isVerified = techData['isVerified'] ?? false;

                if (!isVerified) {
                  return const PendingApprovalScreen();
                }

                // --- THIS IS THE FIX ---
                // Removed 'const' because the compiler thinks the constructor isn't const
                return TechnicianHomeScreen();
                // --- END OF FIX ---
              },
            );
          }
        }

        return const Scaffold(
          body: Center(child: Text('Error: User role not found.')),
        );
      },
    );
  }
}