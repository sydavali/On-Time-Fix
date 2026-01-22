import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:on_time_fix/shared/constants.dart';
import 'package:on_time_fix/screens/login_screen.dart'; 

class CreateTechnicianProfileScreen extends StatefulWidget {
  const CreateTechnicianProfileScreen({super.key});

  @override
  State<CreateTechnicianProfileScreen> createState() =>
      _CreateTechnicianProfileScreenState();
}

class _CreateTechnicianProfileScreenState
    extends State<CreateTechnicianProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final List<String> _selectedSkills = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _selectedSkills.isEmpty) {
      if (_selectedSkills.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one skill.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() { _isLoading = true; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update 'users'
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(userRef, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'profileComplete': true,
      });

      // 2. Update 'technicians'
      final techRef =
          FirebaseFirestore.instance.collection('technicians').doc(user.uid);
      batch.update(techRef, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'experienceYears': int.tryParse(_experienceController.text.trim()) ?? 0,
        'skills': _selectedSkills,
        'profileComplete': true,
        'isVerified': true, // Demo Magic
      });

      await batch.commit();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e")),
        );
      }
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Technician Profile"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                // --- 1. NEW: BIG AVATAR ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50, // Orange tint for technicians
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      size: 64,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Welcome, Technician!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tell us about your skills to get started.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // --- 2. POLISHED INPUTS ---
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) => v!.trim().isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.trim().isEmpty ? "Please enter your phone number" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _experienceController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "Years of Experience (Optional)",
                    prefixIcon: const Icon(Icons.work_history_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                // --- 3. POLISHED SKILLS CARD ---
                const Text(
                  "Select Your Skills",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: serviceCategories.map((category) {
                      final bool isSelected = _selectedSkills.contains(category.name);
                      return FilterChip(
                        label: Text(category.name),
                        avatar: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Icon(category.icon, color: category.color, size: 18),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey.shade300,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedSkills.add(category.name);
                            } else {
                              _selectedSkills.remove(category.name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 40),

                // --- 4. POLISHED BUTTON ---
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save & Continue",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}