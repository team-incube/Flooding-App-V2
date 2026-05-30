import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_size.dart';

/// 앱에서 사용하는 SVG 아이콘 모음.
///
/// 사용 예) `AppIcon.calendar()` 또는 `AppIcon.calendar(size: AppSize.s18)`.
class AppIcon {
  AppIcon._();

  static const String _base = 'assets/icons';

  // Path 상수
  static const String logo = '$_base/logo.svg';
  static const String calendar = '$_base/calender.svg';
  static const String book = '$_base/book.svg';
  static const String chair = '$_base/chair.svg';
  static const String speaker = '$_base/speaker.svg';
  static const String warning = '$_base/warning.svg';
  static const String chevronRight = '$_base/chevron_right.svg';
  static const String dehaze = '$_base/dehaze.svg';
  static const String sparkle = '$_base/sparkle.svg';
  static const String chatBot = '$_base/chat_bot.svg';

  // 메뉴 드로어
  static const String navHome = '$_base/nav_home.svg';
  static const String navDormitory = '$_base/nav_dormitory.svg';
  static const String logout = '$_base/logout.svg';
  static const String withdraw = '$_base/withdraw.svg';
  static const String profileEdit = '$_base/profile_edit.svg';
  static const String avatarBody = '$_base/avatar_body.svg';
  static const String avatarHead = '$_base/avatar_head.svg';

  /// SVG 아이콘 위젯 생성 헬퍼.
  static Widget asset(String path, {double size = AppSize.s24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
