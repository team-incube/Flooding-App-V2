import 'dart:ui' show Radius;

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 공통 라운드(corner radius) 상수.
class AppRadius {
  AppRadius._();

  static double get s4 => 4.0.r;
  static double get s6 => 6.0.r;
  static double get s8 => 8.0.r;
  static double get s12 => 12.0.r;
  static double get s16 => 16.0.r;

  /// [Radius] 타입이 필요한 곳(`BorderRadius.only` 등)에서 사용한다.
  static Radius get r4 => Radius.circular(s4);
  static Radius get r6 => Radius.circular(s6);
  static Radius get r8 => Radius.circular(s8);
  static Radius get r12 => Radius.circular(s12);
  static Radius get r16 => Radius.circular(s16);
}
