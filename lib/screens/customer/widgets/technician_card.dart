import 'package:flutter/material.dart';

class TechnicianCard extends StatelessWidget {
  final String name;
  final double rating;
  final String experience;
  final List<String> skills;
  final VoidCallback onTap;

  const TechnicianCard({
    super.key,
    required this.name,
    required this.rating,
    required this.experience,
    required this.skills,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Name and Rating ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Star Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange[400], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1), // e.g., "4.5"
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              
              // --- Experience ---
              Text(
                "$experience Years Experience",
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12.0),
              
              // --- Skills (show first 3) ---
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: skills.take(3).map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  labelStyle: const TextStyle(fontSize: 12),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}