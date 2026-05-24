import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — warm burnt orange
  static const Color primary = Color(0xFFFA5E2D);
  static const Color primaryLight = Color(0xFFFF855E);
  static const Color primaryDark = Color(0xFFD94614);
  static const Color onPrimary = Colors.white;

  // Secondary — earthy mustard
  static const Color secondary = Color(0xFFE8C872);
  static const Color secondaryLight = Color(0xFFF2DCA3);
  static const Color secondaryDark = Color(0xFFC9A64A);

  // Surfaces (Soft off-white/beige)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F1E7);
  static const Color surfaceContainer = Color(0xFFE5E0D8);
  
  // Changing cardDark to white so existing cards become bright
  static const Color cardDark = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background (Warm light cream)
  // Re-mapping dark to light so existing screens look light without renaming
  static const Color backgroundDark = Color(0xFFF3F1E7);
  static const Color backgroundLight = Color(0xFFF3F1E7);

  // Text (Dark brown/black)
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Status / Card colors (Pastel earthy tones)
  static const Color success = Color(0xFFD4E4D4); // Soft Green
  static const Color warning = Color(0xFFE8C872); // Mustard Yellow
  static const Color error = Color(0xFFE57373);   // Soft Red
  static const Color info = Color(0xFFC2D3E4);    // Soft Blue

  // Task priority
  static const Color priorityKritis = Color(0xFFE57373);
  static const Color priorityTinggi = Color(0xFFFA5E2D);
  static const Color prioritySedang = Color(0xFFE8C872);
  static const Color priorityRendah = Color(0xFFD4E4D4);

  // Task status
  static const Color statusBelum = Color(0xFFC2D3E4);
  static const Color statusProses = Color(0xFFE8C872);
  static const Color statusSelesai = Color(0xFFD4E4D4);
  static const Color statusTerkendala = Color(0xFFE57373);

  // Rundown status
  static const Color rundownBelum = Color(0xFFC2D3E4);
  static const Color rundownBerjalan = Color(0xFFE8C872);
  static const Color rundownSelesai = Color(0xFFD4E4D4);
  static const Color rundownDitunda = Color(0xFFE57373);

  // Borders & Glass (Removed glass effect)
  static const Color glassWhite = Colors.transparent;
  static const Color glassBorder = Colors.transparent;
}
