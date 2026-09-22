import 'package:flutter/material.dart';

/// Palette lifted from the reference UI: warm peach/cream background,
/// a punchy orange accent, near-black CTA buttons, and a teal "done" state
/// for streak check-ins.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFCEEE2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF7E4D6);

  static const Color primary = Color(0xFFF4652C); // warm orange
  static const Color primaryDark = Color(0xFFD84E1B);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color ctaDark = Color(0xFF1E1A18); // near-black buttons
  static const Color onCtaDark = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF2A211D);
  static const Color textSecondary = Color(0xFF8B7A72);
  static const Color textMuted = Color(0xFFB4A79F);

  static const Color streakDone = Color(0xFF3FB89A); // teal check
  static const Color streakToday = primary;
  static const Color streakPending = Color(0xFFE9DCD1);

  static const Color divider = Color(0xFFEBDCD0);
  static const Color error = Color(0xFFD6483A);
}
