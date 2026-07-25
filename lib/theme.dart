import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const bg = Color(0xFFE9EDF2);
  static const shLight = Color(0xFFFFFFFF);
  static const shDark = Color(0xFFC4CBD7);

  static const ink = Color(0xFF2B3240);
  static const inkSoft = Color(0xFF6B7686);
  static const inkFaint = Color(0xFF9AA3B2);
  static const line = Color(0xFFD7DCE4);

  static const blue = Color(0xFF4C7EF3);
  static const blueInk = Color(0xFF2E5FD1);
  static const green = Color(0xFF2FBF83);
  static const greenInk = Color(0xFF1E9C6A);
  static const red = Color(0xFFF0594F);
  static const redInk = Color(0xFFD93F35);
  static const amber = Color(0xFFF5A93F);
  static const amberInk = Color(0xFFD98A1F);
  static const violet = Color(0xFF8B6BF0);
  static const violetInk = Color(0xFF6B46E0);
}

class AppText {
  AppText._();

  static const greeting = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.inkFaint,
  );

  static const screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.2,
  );

  static const h1 = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.2,
  );

  static const sectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.inkSoft,
  );

  static const cardTitle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const body = TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.ink);

  static const caption = TextStyle(fontSize: 12, color: AppColors.inkSoft);

  static const tiny = TextStyle(fontSize: 11, color: AppColors.inkFaint);

  static const statNum = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextStyle mono(double size, {FontWeight weight = FontWeight.w600, Color color = AppColors.ink}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

const kRadiusCard = 20.0;
const kRadiusInput = 16.0;
const kRadiusIcon = 14.0;
const kRadiusPill = 999.0;
