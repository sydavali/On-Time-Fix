import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RateJobScreen extends StatefulWidget {
  final String jobId;
  final String technicianId; // This is the technician's Auth UID

  const RateJobScreen({
    super.key,
    required this.jobId,
    required this.technicianId,
  });

  @override
  State<RateJobScreen> createState() => _RateJobScreenState();
}

class _RateJobScreenState extends State<RateJobScreen> {
  int _rating = 0; // 0 = no rating, 1-5 = star rating
  final _reviewController = TextEditingController();
  bool _isLoading = false;

  // This widget builds our tap-to-rate stars
  Widget _buildStar(int index) {
    IconData icon = (index <= _rating) ? Icons.star : Icons.star_border;
    Color color = (index <= _rating) ? Colors.orange : Colors.grey;

    return IconButton(
      icon: Icon(icon, color: color, size: 40),
      onPressed: () {
        setState(() {
          _rating = index; // Set rating from 1 to 5
        });
      },
    );
  }

  // --- THIS IS THE UPDATED FUNCTION ---
  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { _isLoading = false; });
      return;
    }

    final firestore = FirebaseFirestore.instance;

    try {
      // We need the technician's DOCUMENT ID, not their auth ID, to update them.
      // We stored the Auth ID in the 'uid' field.
      final techQuery = await firestore
          .collection('technicians')
          .where('uid', isEqualTo: widget.technicianId)
          .limit(1)
          .get();

      if (techQuery.docs.isEmpty) {
        throw Exception('Technician document not found.');
      }
      final techDocRef = techQuery.docs.first.reference;

      // Run the entire operation as a transaction
      await firestore.runTransaction((transaction) async {
        // 1. Get the technician's current data
        final techSnapshot = await transaction.get(techDocRef);
        if (!techSnapshot.exists) {
          throw Exception("Technician document does not exist!");
        }

        // 2. Get current rating info (with defaults)
        final double currentRating = (techSnapshot.data()!['rating'] ?? 0.0).toDouble();
        final int jobsCompleted = (techSnapshot.data()!['jobsCompleted'] ?? 0).toInt();

        // 3. Calculate the new average rating
        // (current_total_stars + new_stars) / (new_total_jobs)
        final double newRating = 
            ((currentRating * jobsCompleted) + _rating) / (jobsCompleted + 1);

        // 4. Create the new rating document
        final ratingDocRef = firestore.collection('ratings').doc();
        transaction.set(ratingDocRef, {
          'jobId': widget.jobId,
          'technicianId': widget.technicianId, // The tech's Auth UID
          'customerId': user.uid,
          'stars': _rating,
          'review': _reviewController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        // 5. Update the technician's document
        transaction.update(techDocRef, {
          'rating': newRating, // The new average
          'jobsCompleted': jobsCompleted + 1, // Increment the job count
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e')),
        );
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate This Service'),
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.task_alt,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Job Completed!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please rate your technician to help others.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // --- Interactive Star Rating ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => _buildStar(index + 1)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // --- Review Text Field ---
              TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add an optional review...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Rating', style: TextStyle(fontSize: 16)),
                ),
              ),
              
              // --- Skip Button ---
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}