// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- 1. IMPORT
import 'firebase_options.dart';
import 'screens/splash_screen.dart'; 
import 'app_theme.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      useMaterial3: true,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavyBlue,
        primary: primaryNavyBlue,
        secondary: accentVibrantOrange, 
        background: backgroundOffWhite,
        surface: cardWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryDarkCharcoal,
        onSurface: textPrimaryDarkCharcoal,
        error: errorCrimsonRed,
      ),
      scaffoldBackgroundColor: backgroundOffWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavyBlue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicatorColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        color: cardWhite,
        elevation: 1,
        surfaceTintColor: Colors.transparent, 
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavyBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNavyBlue,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryNavyBlue, width: 2.0),
        ),
      ),
      dividerColor: borderGray,
      
      // --- THIS IS THE FIX ---
      // We apply the 'Roboto' font to our existing TextTheme
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimaryDarkCharcoal),
          displayMedium: TextStyle(color: textPrimaryDarkCharcoal),
          displaySmall: TextStyle(color: textPrimaryDarkCharcoal),
          headlineLarge: TextStyle(color: textPrimaryDarkCharcoal),
          headlineMedium: TextStyle(color: textPrimaryDarkCharcoal),
          headlineSmall: TextStyle(color: textPrimaryDarkCharcoal, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: textPrimaryDarkCharcoal, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: textPrimaryDarkCharcoal),
          titleSmall: TextStyle(color: textPrimaryDarkCharcoal),
          bodyLarge: TextStyle(color: textPrimaryDarkCharcoal),
          bodyMedium: TextStyle(color: textPrimaryDarkCharcoal),
          bodySmall: TextStyle(color: textPrimaryDarkCharcoal),
          labelLarge: TextStyle(color: textPrimaryDarkCharcoal),
          labelMedium: TextStyle(color: textPrimaryDarkCharcoal),
          labelSmall: TextStyle(color: textPrimaryDarkCharcoal),
        ),
      ),
      // --- The duplicated 'textTheme' block below is now gone ---
    );

    // Apply the theme to your app
    return MaterialApp(
      title: 'On Time Fix',
      theme: theme, 
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), 
    );
  }
}