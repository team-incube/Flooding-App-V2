import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_size.dart';

/// 아이콘 위젯 팩토리 시그니처(= AppIcon 각 아이콘 메서드의 tear-off 타입).
///
/// 아이콘을 직접 그리지 않고 크기·색을 호출부가 정하도록 넘길 때 쓴다.
typedef AppIconBuilder = Widget Function({double size, Color? color});

/// 앱에서 사용하는 SVG 아이콘 모음.
///
/// 각 아이콘은 위젯을 반환하는 메서드다. 크기·색은 선택 인자로 조절한다.
/// 사용 예) `AppIcon.calendar()` 또는 `AppIcon.calendar(size: AppSize.s18)`.
class AppIcon {
  AppIcon._();

  static const String _base = 'assets/icons';

  // 공통
  static Widget logo({double size = AppSize.s24, Color? color}) =>
      _svg('logo.svg', size: size, color: color);
  static Widget calendar({double size = AppSize.s24, Color? color}) =>
      _svg('calender.svg', size: size, color: color);
  static Widget book({double size = AppSize.s24, Color? color}) =>
      _svg('book.svg', size: size, color: color);
  static Widget chair({double size = AppSize.s24, Color? color}) =>
      _svg('chair.svg', size: size, color: color);
  static Widget speaker({double size = AppSize.s24, Color? color}) =>
      _svg('speaker.svg', size: size, color: color);
  static Widget warning({double size = AppSize.s24, Color? color}) =>
      _svg('warning.svg', size: size, color: color);
  static Widget chevronRight({double size = AppSize.s24, Color? color}) =>
      _svg('chevron_right.svg', size: size, color: color);
  static Widget chevronLeft({double size = AppSize.s24, Color? color}) =>
      _svg('chevron_left.svg', size: size, color: color);
  static Widget camera({double size = AppSize.s24, Color? color}) =>
      _svg('camera.svg', size: size, color: color);
  static Widget check({double size = AppSize.s24, Color? color}) =>
      _svg('check.svg', size: size, color: color);
  static Widget uncheck({double size = AppSize.s24, Color? color}) =>
      _svg('non_check.svg', size: size, color: color);
  static Widget dehaze({double size = AppSize.s24, Color? color}) =>
      _svg('dehaze.svg', size: size, color: color);
  static Widget sparkle({double size = AppSize.s24, Color? color}) =>
      _svg('sparkle.svg', size: size, color: color);
  static Widget chatBot({double size = AppSize.s24, Color? color}) =>
      _svg('chat_bot.svg', size: size, color: color);
  static Widget female({double size = AppSize.s24, Color? color}) =>
      _svg('female.svg', size: size, color: color);
  static Widget male({double size = AppSize.s24, Color? color}) =>
      _svg('male.svg', size: size, color: color);
  static Widget filter({double size = AppSize.s24, Color? color}) =>
      _svg('filter.svg', size: size, color: color);
  static Widget graduationCap({double size = AppSize.s24, Color? color}) =>
      _svg('graduation_cap.svg', size: size, color: color);
  /// 프로필 편집 뱃지 아이콘.
  static Widget profileEdit({double size = AppSize.s24, Color? color}) =>
      _svg('profile_edit.svg', size: size, color: color);
  static Widget heart({double size = AppSize.s24, Color? color}) =>
      _svg('heart.svg', size: size, color: color);
  static Widget filledHeart({double size = AppSize.s24, Color? color}) =>
      _svg('filled_heart.svg', size: size, color: color);
  static Widget back({double size = AppSize.s24, Color? color}) =>
      _svg('back.svg', size: size, color: color);
  static Widget search({double size = AppSize.s24, Color? color}) =>
      _svg('search.svg', size: size, color: color);
  static Widget medalGold({double size = AppSize.s24, Color? color}) =>
      _svg('medal_gold.svg', size: size, color: color);
  static Widget medalSilver({double size = AppSize.s24, Color? color}) =>
      _svg('medal_silver.svg', size: size, color: color);
  static Widget medalBronze({double size = AppSize.s24, Color? color}) =>
      _svg('medal_bronze.svg', size: size, color: color);



  // 메뉴 드로어
  static Widget navHome({double size = AppSize.s24, Color? color}) =>
      _svg('nav_home.svg', size: size, color: color);
  static Widget dormitoryOutline({double size = AppSize.s24, Color? color}) =>
      _svg('dormitory_outline.svg', size: size, color: color);
  static Widget dormitoryFill({double size = AppSize.s24, Color? color}) =>
      _svg('dormitory_fill.svg', size: size, color: color);
  static Widget logout({double size = AppSize.s24, Color? color}) =>
      _svg('logout.svg', size: size, color: color);
  static Widget withdraw({double size = AppSize.s24, Color? color}) =>
      _svg('withdraw.svg', size: size, color: color);
  static Widget trash({double size = AppSize.s24, Color? color}) =>
      _svg('trash.svg', size: size, color: color);

  /// 프로필 기본 아바타(52px, 풀컬러라 색 인자는 두지 않는다).
  static Widget avatar({double size = AppSize.s52}) =>
      _svg('avatar.svg', size: size);

  /// SVG 위젯 생성 헬퍼.
  static Widget _svg(String name, {required double size, Color? color}) {
    return SvgPicture.asset(
      '$_base/$name',
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
