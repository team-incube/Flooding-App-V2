import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  static TextStyle get title1 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32.sp,
    fontWeight: bold, // Bold
    height: _lineHeight,
  );
  static TextStyle get title2 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.sp,
    fontWeight: bold, // Bold
    height: _lineHeight,
  );
  static TextStyle get title3 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.sp,
    fontWeight: semiBold, // SemiBold
    height: _lineHeight,
  );
  static TextStyle get title4 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.sp,
    fontWeight: medium, // medium
    height: _lineHeight,
  );

  // Text
  static TextStyle get text1 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.sp,
    fontWeight: semiBold, // SemiBold
    height: _lineHeight,
  );
  static TextStyle get text2 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: semiBold, // SemiBold
    height: _lineHeight,
  );
  static TextStyle get text3 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );
  static TextStyle get text4 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15.sp,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );

  // Caption
  static TextStyle get caption1 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );
  static TextStyle get caption2 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.sp,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );
  static TextStyle get caption3 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: medium, // Medium
    height: _lineHeight,
  );
}
