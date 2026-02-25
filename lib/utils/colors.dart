import 'package:flutter/material.dart';

class FloBloomColors {
  static const primaryLight = Color(0xFFE8B7C8);
  static const primaryDeep = Color(0xFFD89AB5);
  static const accentGold1 = Color(0xFFF4D7E0);
  static const accentGold2 = Color(0xFFE8C3D1);
  static const accentGold3 = Color(0xFFF9E8E0);
  static const background = Color(0xFFF9E8F0);
  static const textPrimary = Color(0xFF4A2E3A);
  static const textSecondary = Color(0xFF8C6F7F);
  static const fireflyGreen = Color(0xFFD4F0E2);
  static const petalPurple = Color(0xFFD7BDE2);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDeep],
  );
}
