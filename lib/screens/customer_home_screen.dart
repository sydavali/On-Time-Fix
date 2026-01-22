// lib/screens/customer_home_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart'; // <-- MAKE SURE THIS IMPORT IS HERE
import 'technician_search_screen.dart';
import 'my_bookings_screen.dart'; 

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Plumbing', 'icon': Icons.plumbing},
    {'name': 'Electrical', 'icon': Icons.electrical_services},
    {'name': 'Carpentry', 'icon': Icons.construction},
    {'name': 'Appliance Repair', 'icon': Icons.local_laundry_service},
    {'name': 'Painting', 'icon': Icons.format_paint},
    {'name': 'AC Repair', 'icon': Icons.ac_unit},
  ];

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Service'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyBookingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                // --- THIS IS THE FIX ---
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()), // const is back
                  (Route<dynamic> route) => false, // Comma is added
                );
                // -----------------------
              }
            },
          ),
        ],
      ),
      // (The rest of the file is the same)
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(
            title: category['name'],
            icon: category['icon'],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TechnicianListScreen(
                    category: category['name'],
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

// Helper widget (no changes)
class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}