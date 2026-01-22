import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:on_time_fix/screens/customer/widgets/technician_card.dart';
import 'package:on_time_fix/screens/customer/booking_form_screen.dart';
import 'package:on_time_fix/shared/ui_helpers.dart';

class TechnicianListScreen extends StatelessWidget {
  final String category;

  const TechnicianListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // I am using the [Primary Blue] theme we established.
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        // FIX: Added curly braces for correct interpolation
        title: Text("${category}s"), 
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('technicians')
            .where('skills', arrayContains: category)
            .where('isAvailable', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 5,
              itemBuilder: (context, index) => const SkeletonTechnicianCard(),
            );
          }

          if (snapshot.hasError) {
            return const EmptyStateWidget(
              icon: Icons.error_outline,
              title: "Something went wrong",
              message: "We couldn't load the technician list. Please try again later.",
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.search_off,
              // FIX: Added curly braces here too
              title: "No ${category}s Found", 
              message: "It looks like no one is available right now. Try checking another category.",
              onRetry: () => Navigator.pop(context),
            );
          }

          final technicians = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final techDoc = technicians[index];
              final techData = techDoc.data() as Map<String, dynamic>;
              final List<String> skills = List<String>.from(techData['skills'] ?? []);

              return TechnicianCard(
                name: techData['name'] ?? 'No Name',
                rating: (techData['rating'] ?? 0.0).toDouble(),
                experience: (techData['experienceYears'] ?? 0).toString(),
                skills: skills,
                onTap: () {
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(
          technicianId: techAuthId,
          technicianName: techData['name'] ?? 'Technician',
        ),
      ),
    );
  }
}