import 'package:flutter/material.dart';

class AppConstants {
  static const Color primaryColor = Color(0xFF1E3A8A); // Dark blue
  static const Color cardColor = Color(0xFF3B82F6); // Lighter blue for cards
  static const Color accentColor = Colors.yellow; // For progress bars
  static const Color textColor = Colors.white;
  static const Color navColor = Colors.green;
  static const String appTitle = 'Personal Finance Tracker';
  static BoxDecoration gradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Colors.blueAccent, Colors.cyanAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
  );
}