import 'package:flutter/material.dart';

/// 앱 텍스트 스타일 (Figma Typography 가이드 기준, SUIT)
class AppFont {
  AppFont._();

  static const String _fontFamily = 'SUIT';

  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Title
  static const TextStyle title1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: bold, // Bold
  );
  static const TextStyle title2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: semiBold, // SemiBold
  );
  static const TextStyle title3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: semiBold, // SemiBold
  );

  // Text
  static const TextStyle text1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: semiBold, // SemiBold
  );
  static const TextStyle text2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: medium, // Medium
  );
  static const TextStyle text3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: medium, // Medium
  );

  // Caption
  static const TextStyle caption1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: medium, // Medium
  );
  static const TextStyle caption2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: medium, // Medium
  );
  static const TextStyle caption3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: medium, // Medium
  );
}
