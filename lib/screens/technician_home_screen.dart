import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // --- NEW IMPORT ---
import '../services/auth_service.dart';
import 'package:on_time_fix/screens/login_screen.dart'; 
import 'package:on_time_fix/screens/edit_profile_screen.dart'; 
import 'package:on_time_fix/shared/ui_helpers.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen>
    with SingleTickerProviderStateMixin { 
  late TabController _tabController;
  final String _currentTechId = FirebaseAuth.instance.currentUser!.uid;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _acceptJob(BuildContext context, String jobId, String techAuthId) async {
    try {
      final techQuery = await _firestore
          .collection('technicians')
          .where('uid', isEqualTo: techAuthId)
          .limit(1)
          .get();
      if (techQuery.docs.isEmpty) throw Exception("Could not find technician document.");
      
      final String techDocId = techQuery.docs.first.id;
      await _firestore.runTransaction((transaction) async {
        final jobDocRef = _firestore.collection('serviceRequests').doc(jobId);
        final techDocRef = _firestore.collection('technicians').doc(techDocId);
        final techDoc = await transaction.get(techDocRef);
        if (!techDoc.exists) throw Exception("Tech doc missing");
        
        transaction.update(jobDocRef, {'status': 'in-progress'});
        transaction.update(techDocRef, {'isAvailable': false});
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job accepted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _rejectJob(BuildContext context, String jobId) async {
    try {
      await _firestore.collection('serviceRequests').doc(jobId).update({'status': 'rejected'});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job rejected.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Dashboard'),
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
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'PENDING', icon: Icon(Icons.hourglass_top)),
            Tab(text: 'IN-PROGRESS', icon: Icon(Icons.construction)),
            Tab(text: 'HISTORY', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobsList(status: 'pending', techId: _currentTechId),
          _buildJobsList(status: 'in-progress', techId: _currentTechId),
          _buildJobsList(status: 'history', techId: _currentTechId),
        ],
      ),
    );
  }

  Widget _buildJobsList({required String status, required String techId}) {
    Query query = _firestore
        .collection('serviceRequests')
        .where('technicianId', isEqualTo: techId);

    if (status == 'history') {
      query = query.where('status', whereIn: ['completed', 'rejected']);
    } else {
      query = query.where('status', isEqualTo: status);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) => const SkeletonTechnicianCard(),
          );
        }
        if (snapshot.hasError) {
          return const EmptyStateWidget(icon: Icons.error_outline, title: "Error", message: "Could not load jobs.");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          String title = "All Caught Up";
          String message = "No jobs found here.";
          IconData icon = Icons.check_circle_outline;

          if (status == 'pending') {
            title = "No Pending Requests";
            message = "Wait for customers to book your services.";
            icon = Icons.notifications_none;
          } else if (status == 'in-progress') {
            title = "No Active Jobs";
            message = "Accept a pending request to start working.";
            icon = Icons.handyman_outlined;
          } else if (status == 'history') {
            title = "No History Yet";
            message = "Your completed jobs will appear here.";
            icon = Icons.history;
          }

          return EmptyStateWidget(icon: icon, title: title, message: message);
        }
        
        final jobs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            final data = job.data() as Map<String, dynamic>;
            final String jobId = job.id;
            
            return _JobCard(
              jobData: data,
              jobId: jobId,
              techId: techId,
              status: data['status'] ?? 'Unknown', 
              onAccept: () => _acceptJob(context, jobId, techId),
              onReject: () => _rejectJob(context, jobId),
            );
          },
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String jobId;
  final String techId;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _JobCard({
    super.key, 
    required this.jobData,
    required this.jobId,
    required this.techId,
    required this.status,
    required this.onAccept,
    required this.onReject,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in-progress': return Colors.blue;
      case 'completed': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  // --- NEW: Helper to launch phone dialer ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Could not launch phone dialer");
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final String priority = jobData['priority'] ?? 'Normal';
    final bool isUrgent = priority == 'Urgent';
    final String customerPhone = jobData['customerPhone'] ?? ''; // --- GET PHONE ---

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "CUSTOMER",
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                                Text(
                                  jobData['customerName'] ?? 'Unknown', 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // --- CALL BUTTON (Only if phone exists) ---
                          if (customerPhone.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.phone, color: Colors.green),
                              onPressed: () => _makePhoneCall(customerPhone),
                            ),
                          // -------------------------------------------
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Priority Badge (Moved here to save space)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUrgent ? Colors.red[50] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isUrgent ? Colors.red.shade200 : Colors.blue.shade200),
                        ),
                        child: Text(
                          "$priority Priority",
                          style: TextStyle(
                            color: isUrgent ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),

                      const Divider(height: 24),
                      
                      _buildInfoRow(Icons.location_on_outlined, jobData['address'] ?? 'No address provided'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.build_outlined, jobData['description'] ?? 'No description provided'),
                      
                      const SizedBox(height: 20),

                      if (status == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onReject,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: onAccept,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Accept Job'),
                              ),
                            ),
                          ],
                        )
                      else if (status == 'in-progress')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: const Center(
                            child: Text(
                              "Job is Active - Go to Location",
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              status == 'completed' ? Icons.check_circle : Icons.cancel,
                              color: status == 'completed' ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status == 'completed' ? "Successfully Completed" : "Job Declined",
                              style: TextStyle(
                                color: status == 'completed' ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}