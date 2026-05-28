import 'package:flutter/material.dart';

/// 앱 텍스트 스타일 (Figma Typography 가이드 기준, SUIT)
class AppFont {
  AppFont._();

  static const String _fontFamily = 'SUIT';

  // Title
  static const TextStyle title1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
  );
  static const TextStyle title2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
  );
  static const TextStyle title3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
  );

  // Text
  static const TextStyle text1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
  );
  static const TextStyle text2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
  );
  static const TextStyle text3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500, // Medium
  );

  // Caption
  static const TextStyle caption1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
  );
  static const TextStyle caption2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500, // Medium
  );
  static const TextStyle caption3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
  );
}
