import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingFormScreen extends StatefulWidget {
  final String technicianId; // The Auth UID of the technician
  final String technicianName;

  const BookingFormScreen({
    super.key,
    required this.technicianId,
    required this.technicianName,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController(); 
  final _phoneController = TextEditingController(); 
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isFetchingData = true; 
  String _priority = 'Normal'; 

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); 
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data?['address'] != null) {
            _addressController.text = data!['address'];
          }
          if (data?['phone'] != null) {
            _phoneController.text = data!['phone'];
          }
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
    
    if (mounted) {
      setState(() {
        _isFetchingData = false; 
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final customerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final String customerName = customerDoc.data()?['name'] ?? 'Unknown Customer';

      await FirebaseFirestore.instance.collection('serviceRequests').add({
        'customerId': user.uid,
        'customerEmail': user.email, 
        'customerName': customerName,
        'customerPhone': _phoneController.text.trim(), 
        'technicianId': widget.technicianId, 
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(), 
        'priority': _priority, 
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service Requested Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating request: $e")),
        );
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Request Service'),
        elevation: 0,
      ),
      body: _isFetchingData 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TECHNICIAN INFO CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Booking Technician",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                widget.technicianName,
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Chip(
                            label: Text("Verified"),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                            visualDensity: VisualDensity.compact,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. CONTACT NUMBER
                    const Text(
                      "Contact Number",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Enter mobile number",
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        helperText: "You can change this if booking for someone else",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a phone number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 3. ADDRESS INPUT
                    const Text(
                      "Service Location",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: "Enter House No, Street, Area",
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 4. PROBLEM DESCRIPTION
                    const Text(
                      "Problem Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Describe the issue clearly...",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe your issue.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 5. PRIORITY SELECTOR
                    const Text(
                      "Urgency Level",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _PriorityCard(
                            label: "Normal",
                            isSelected: _priority == 'Normal',
                            color: Colors.blue,
                            onTap: () => setState(() => _priority = 'Normal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PriorityCard(
                            label: "Urgent",
                            isSelected: _priority == 'Urgent',
                            color: Colors.red,
                            onTap: () => setState(() => _priority = 'Urgent'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 6. SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Confirm Booking',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    // Add extra space at bottom for scrolling
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ), // Closes Padding
          ), // Closes SingleChildScrollView
    ); // Closes Scaffold
  }
}

// HELPER WIDGET
class _PriorityCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _PriorityCard({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}