import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:on_time_fix/screens/customer/widgets/technician_card.dart';

// 1. IMPORT YOUR NEW BOOKING FORM SCREEN
// (Assuming it's in the same 'customer' folder)
import 'package:on_time_fix/screens/customer/booking_form_screen.dart';

class TechnicianListScreen extends StatelessWidget {
  final String category;

  const TechnicianListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Your fix was correct
        title: Text("${category}s Available"), // e.g., "Plumbers Available"
      ),
      body: StreamBuilder<QuerySnapshot>(
        // --- This is the core Firebase query ---
        stream: FirebaseFirestore.instance
            .collection('technicians')
            .where('skills', arrayContains: category) // Find techs with this skill
            .where('isAvailable', isEqualTo: true) // Only if they are available
            .snapshots(),
        // ------------------------------------

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                // Your fix was correct
                'No available ${category}s found right now.',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          final technicians = snapshot.data!.docs;

          // --- We have techs! Build the list. ---
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final techDoc = technicians[index];
              final techData = techDoc.data() as Map<String, dynamic>;

              // Load data with safety checks
              final List<String> skills = List<String>.from(techData['skills'] ?? []);

              return TechnicianCard(
                name: techData['name'] ?? 'No Name',
                rating: (techData['rating'] ?? 0.0).toDouble(),
                experience: (techData['experienceYears'] ?? 0).toString(),
                skills: skills,
                onTap: () {
                  // 2. PASS THE 'uid' FIELD (the Auth ID)
                  _onTechnicianTapped(context, techData['uid'], techData);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _onTechnicianTapped(BuildContext context, String techAuthId, Map<String, dynamic> techData) {
    // This is where we go to the booking form
    print("Tapped on tech: ${techData['name']}");
    
    // 3. --- UNCOMMENTED THIS NAVIGATION ---
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(
          technicianId: techAuthId, // Pass the technician's Auth UID
          technicianName: techData['name'],
        ),
      ),
    );
  }
}