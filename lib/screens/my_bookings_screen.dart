// lib/screens/my_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. Query the 'serviceRequests' collection
        stream: FirebaseFirestore.instance
            .collection('serviceRequests')
            // 2. Filter for jobs where 'customerId' matches the logged-in user
            .where('customerId', isEqualTo: currentUserId)
            // 3. Order by most recent
            .orderBy('createdAt', descending: true)
            .snapshots(),
        
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have not booked any services yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // 4. We have data!
          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;
              
              // Get the status and give it a color
              final String status = data['status'];
              final Color statusColor;

              switch (status) {
                case 'pending':
                  statusColor = Colors.orange;
                  break;
                case 'in-progress':
                  statusColor = Colors.blue;
                  break;
                case 'completed':
                  statusColor = Colors.green;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.all(12.0),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Align(
                        alignment: Alignment.topRight,
                        child: Chip(
                          label: Text(
                            status.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: statusColor,
                        ),
                      ),
                      Text(
                        'Tech: ${data['technicianName']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Issue: ${data['description']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}