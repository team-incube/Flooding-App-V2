import 'dart:ui' show Radius;

/// 공통 라운드(corner radius) 상수.
class AppRadius {
  AppRadius._();

  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;

  /// [Radius] 타입이 필요한 곳(`BorderRadius.only` 등)에서 사용한다.
  static const Radius r4 = Radius.circular(s4);
  static const Radius r6 = Radius.circular(s6);
  static const Radius r8 = Radius.circular(s8);
  static const Radius r12 = Radius.circular(s12);
  static const Radius r16 = Radius.circular(s16);
}
