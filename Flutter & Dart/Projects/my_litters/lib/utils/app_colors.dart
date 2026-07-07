import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1A3A8A);
  static const Color primaryLight = Color(0xFF2E5C9E);

  // Backgrounds
  static const Color scaffold = Color(0xFFF5F5F5);
  static const Color scaffoldAlt = Color(0xFFF8F9FA);
  static const Color cardWhite = Colors.white;
  static const Color subscriptionBackground = Color(0xFFEFEFEF);

  // Fuel types
  static const Color fuel91 = Color(0xFF43A047);
  static const Color fuel95 = Color(0xFFE53935);
  static const Color fuelDiesel = Color(0xFFFFC107);

  // Status
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF0984E3);
  static const Color success = Color(0xFF43A047);

  // Subscription fuel price boxes (match subcriptions.dart originals)
  static const Color fuelGreen = Color(0xFF4CAF50);
  static const Color fuelRed = Color(0xFFF44336);
  static const Color fuelAmber = Color(0xFFFFC107);

  // Login button
  static const Color loginButton = Color.fromARGB(255, 162, 163, 165);
}
