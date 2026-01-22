import 'package:flutter/material.dart';

// This is our single, central list for all service categories
// Both customers and technicians will use this.

class ServiceCategory {
  final String name;
  final IconData icon;
  final Color color;

  ServiceCategory({required this.name, required this.icon, required this.color});
}

final List<ServiceCategory> serviceCategories = [
  ServiceCategory(name: "Plumber", icon: Icons.water_drop, color: Colors.blue),
  ServiceCategory(name: "Electrician", icon: Icons.bolt, color: Colors.orange),
  ServiceCategory(name: "Carpenter", icon: Icons.construction, color: Colors.brown),
  ServiceCategory(name: "AC Repair", icon: Icons.ac_unit, color: Colors.lightBlue),
  ServiceCategory(name: "Painting", icon: Icons.format_paint, color: Colors.purple),
  ServiceCategory(name: "Cleaning", icon: Icons.cleaning_services, color: Colors.green),
  ServiceCategory(name: "Appliance Repair", icon: Icons.blender, color: Colors.grey),
  ServiceCategory(name: "More", icon: Icons.more_horiz, color: Colors.black54),
];