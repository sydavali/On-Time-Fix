import 'dart:async';
import 'package:flutter/material.dart';
import 'package:on_time_fix/screens/auth_director.dart'; // Make sure this import matches your file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 1. Setup the Fade Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // 2. Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthDirector(), // Goes to Auth check
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- YOUR NEW LOGO ---
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/icon/icon.png'), // Your logo file
                    fit: BoxFit.contain,
                  ),
                  // Optional: Add a soft shadow to make it "pop"
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // --- APP NAME ---
              Text(
                "ON TIME FIX",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900, // Extra Bold
                  letterSpacing: 1.5,
                  color: Theme.of(context).primaryColor, // Matches your Blue
                ),
              ),
              
              const SizedBox(height: 10),
              
              // --- TAGLINE ---
              const Text(
                "Fast. Reliable. Verified.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}