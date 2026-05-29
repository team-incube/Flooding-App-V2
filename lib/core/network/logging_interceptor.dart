import 'dart:convert';

import 'package:dio/dio.dart';

import '../utils/logger.dart';

/// 디버그용 dio 로깅 인터셉터.
///
/// 요청(메서드/엔드포인트/보낸 데이터), 응답(상태/받은 데이터),
/// 소요 시간(ms), 에러 시 서버 응답까지 한눈에 보이도록 출력한다.
class LoggingInterceptor extends Interceptor {
  static const String _tag = 'API';
  static const String _startKey = '_req_start_ms';

  static const String _divider =
      '────────────────────────────────────────';

  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer()
      ..writeln(_divider)
      ..writeln('⇢ ${options.method} ${options.uri}');
    if (options.data != null) {
      buffer.writeln('  body: ${_pretty(options.data)}');
    }
    Logger.d(buffer.toString().trimRight(), tag: _tag);

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final buffer = StringBuffer()
      ..writeln(_divider)
      ..writeln(
        '⇠ ${response.statusCode} ${options.method} ${options.uri}'
        ' · ${_elapsedMs(options)}ms',
      )
      ..write('  data: ${_pretty(response.data)}');
    Logger.d(buffer.toString().trimRight(), tag: _tag);

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode ?? '-';
    final buffer = StringBuffer()
      ..writeln(_divider)
      ..writeln(
        '✗ $status ${options.method} ${options.uri}'
        ' · ${_elapsedMs(options)}ms',
      )
      ..writeln('  type: ${err.type.name}');
    if (err.response?.data != null) {
      buffer.write('  response: ${_pretty(err.response!.data)}');
    } else {
      buffer.write('  message: ${err.message}');
    }
    Logger.e(buffer.toString().trimRight(), tag: _tag);

    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final start = options.extra[_startKey];
    if (start is! int) return -1;
    return DateTime.now().millisecondsSinceEpoch - start;
  }

  /// Map/List/JSON 문자열은 들여쓰기 정렬, 그 외는 그대로 출력한다.
  String _pretty(dynamic data) {
    try {
      if (data is String) {
        final trimmed = data.trim();
        if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
          return _encoder.convert(jsonDecode(trimmed));
        }
        return data;
      }
      if (data is Map || data is List) {
        return _encoder.convert(data);
      }
    } catch (_) {
      // 파싱 실패 시 원본 그대로.
    }
    return data.toString();
  }
}
