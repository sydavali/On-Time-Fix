import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:on_time_fix/screens/edit_profile_screen.dart';
import 'package:on_time_fix/screens/login_screen.dart'; 
import 'package:on_time_fix/screens/customer/rate_job_screen.dart';
import 'package:on_time_fix/shared/ui_helpers.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _cancelJob(String jobId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestore.collection('serviceRequests').doc(jobId).update({
        'status': 'cancelled',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking cancelled.")),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _completeJob(
      BuildContext context, String jobId, String techAuthId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Completion'),
          content: const Text('Are you sure the technician has completed this job?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Yes, Mark Complete'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == null || !confirmed) return;
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing...')));

    try {
      final techQuery = await _firestore.collection('technicians').where('uid', isEqualTo: techAuthId).limit(1).get();
      if (techQuery.docs.isEmpty) throw Exception("Technician not found.");
      final String techDocId = techQuery.docs.first.id;

      await _firestore.runTransaction((transaction) async {
        final jobDocRef = _firestore.collection('serviceRequests').doc(jobId);
        final techDocRef = _firestore.collection('technicians').doc(techDocId);
        final techDoc = await transaction.get(techDocRef);
        if (!techDoc.exists) throw Exception("Technician doc missing");

        transaction.update(jobDocRef, {'status': 'completed'});
        transaction.update(techDocRef, {'isAvailable': true});
      });

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RateJobScreen(jobId: jobId, technicianId: techAuthId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text("My Bookings"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: "Edit Profile",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('serviceRequests')
            .where('customerId', isEqualTo: _currentUserId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 3,
              itemBuilder: (context, index) => const SkeletonTechnicianCard(),
            );
          }

          if (snapshot.hasError) {
            return const EmptyStateWidget(
              icon: Icons.error_outline,
              title: "Error Loading Bookings",
              message: "We couldn't fetch your history.",
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.calendar_today_outlined,
              title: "No Bookings Yet",
              message: "When you book a service, you can track it here.",
            );
          }

          final bookings = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;
              final String jobId = booking.id;
              final String status = data['status'] ?? 'Unknown';
              final String technicianId = data['technicianId'] ?? '';

              return _BookingCard(
                data: data,
                status: status,
                onComplete: () => _completeJob(context, jobId, technicianId),
                onCancel: () => _cancelJob(jobId),
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String status;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.data,
    required this.status,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['description'] ?? 'No description',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // --- THIS IS THE FIXED BUTTON ---
            if (status == 'in-progress')
              SizedBox(
                width: double.infinity,
                height: 50, // Slightly taller for better touch target
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    foregroundColor: Colors.white, // FORCE TEXT WHITE
                    elevation: 0, // CLEAN FLAT LOOK
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Mark as Complete', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold) // BOLD TEXT
                  ),
                ),
              )
            // ---------------------------------
            
            else if (status == 'completed')
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Job Completed',
                      style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              )
            else if (status == 'pending')
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Waiting for technician...',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Cancel"),
                  ),
                ],
              )
            else if (status == 'cancelled')
               const Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Booking Cancelled',
                      style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              )
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in-progress': return Colors.blue;
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      default: return Colors.black;
    }
  }
}