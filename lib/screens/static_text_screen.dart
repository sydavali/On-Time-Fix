import 'package:flutter/material.dart';

class StaticTextScreen extends StatelessWidget {
  final String title;
  final String content;

  const StaticTextScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          // --- EXCELLENT UI: Paper Look ---
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Header Line
              Row(
                children: [
                  Icon(Icons.description_outlined, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.grey[500],
                      letterSpacing: 1.0
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              
              // The Content
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16, 
                  height: 1.6, // Better line spacing for reading
                  color: Colors.black87
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}