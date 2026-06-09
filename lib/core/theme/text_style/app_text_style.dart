import 'package:flutter/material.dart';

/// 앱 텍스트 스타일 (Figma Typography 가이드 기준, SUIT)
class AppTextStyle {
  AppTextStyle._();

  static const String _fontFamily = 'SUIT';

  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Figma Typography 토큰의 lineHeight 100% 기준. 폰트 기본 leading 여백 제거.
  static const double _lineHeight = 1.0;

  // Title
  static const TextStyle title1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: bold, // Bold
    height: _lineHeight,
  );
  static const TextStyle title2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: semiBold, // SemiBold
    height: _lineHeight,
  );
  static const TextStyle title3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: semiBold, // SemiBold
    height: _lineHeight,
  );

  // Text
  static const TextStyle text1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: semiBold, // SemiBold
    height: _lineHeight,
  );
  static const TextStyle text2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );
  static const TextStyle text3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );

  static const TextStyle text4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: medium,
    height: _lineHeight,
  );

  // Caption
  static const TextStyle caption1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );
  static const TextStyle caption2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );
  static const TextStyle caption3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );
}
