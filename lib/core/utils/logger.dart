import 'package:flutter/foundation.dart';

/// 앱 로거.
///
/// debug·profile 모드에서 콘솔(`flutter run` stdout)로 출력하고, release 에서는
/// 아무것도 출력하지 않는다(토큰 노출·성능 보호).
///
/// `dart:developer` 의 `log` 대신 [debugPrint] 를 쓴다 — `flutter run` 터미널은
/// `developer.log` 의 로깅 스트림을 표시하지 않아, `flooding prod`(디버그)·
/// `flooding profile` 실행 시 로그가 보이지 않았다.
class Logger {
  Logger._();

  static void d(String message, {String? tag}) {
    if (kReleaseMode) return;
    debugPrint('[${tag ?? 'DEBUG'}] $message');
  }

  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    debugPrint('[${tag ?? 'ERROR'}] $message');
    if (error != null) debugPrint('  error: $error');
    if (stackTrace != null) debugPrint('  stack: $stackTrace');
  }
}
