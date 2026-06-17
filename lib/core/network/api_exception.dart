import 'package:dio/dio.dart';

/// 앱 전반에서 사용하는 정규화된 요청 예외.
///
/// [DioException] 의 상태 코드·타임아웃 판정·서버 메시지 추출을 한곳에 모아,
/// 각 레포지토리가 같은 변환 로직을 중복 구현하지 않도록 한다. 상태 코드의
/// *의미*(예: 자습 409 = "이미 신청")가 필요한 일부 경우만 레포가 [message]
/// 를 직접 지정해 던지고, 나머지는 서버 메시지 또는 일반 fallback 을 쓴다.
class ApiException implements Exception {
  const ApiException({this.statusCode, this.serverMessage, this.isNetwork = false});

  /// 클라이언트 측 검증 실패 등, 직접 사용자 메시지를 지정해 던질 때 사용.
  const ApiException.message(String message)
    : statusCode = null,
      serverMessage = message,
      isNetwork = false;

  /// [DioException] 을 정규화한다 — 타임아웃/연결 실패 여부, 상태 코드,
  /// 서버 `message` 필드를 한 번에 추출한다.
  factory ApiException.fromDio(DioException e) => ApiException(
    statusCode: e.response?.statusCode,
    serverMessage: _serverMessage(e),
    isNetwork: _isNetwork(e),
  );

  /// 백엔드 HTTP 상태 코드. 네트워크 오류·클라이언트 검증이면 null.
  final int? statusCode;

  /// 백엔드가 내려준 `message` 필드(있으면). 사용자 노출 시 우선한다.
  final String? serverMessage;

  /// 타임아웃·연결 실패 여부.
  final bool isNetwork;

  /// 네트워크 연결 실패·타임아웃 시 노출하는 표준 메시지. 인터셉터·컨트롤러가
  /// 같은 문구를 쓰도록 단일 출처로 둔다.
  static const String networkMessage = '네트워크 연결을 확인해 주세요.';

  /// 사용자에게 노출할 메시지. 서버 메시지가 있으면 그대로 쓰고,
  /// 없으면 상태 코드에 대한 일반적인 한국어 fallback 을 반환한다.
  String get message {
    if (isNetwork) return networkMessage;
    final server = serverMessage;
    if (server != null && server.isNotEmpty) return server;
    return switch (statusCode) {
      400 => '요청을 처리할 수 없어요.',
      401 => '로그인이 필요해요.',
      403 => '권한이 없어요.',
      404 => '요청한 정보를 찾을 수 없어요.',
      409 => '이미 처리되었거나 처리할 수 없는 상태예요.',
      _ => '요청을 처리하지 못했어요.',
    };
  }

  @override
  String toString() => 'ApiException(status: $statusCode, network: $isNetwork): $message';

  static String? _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    return null;
  }

  static bool _isNetwork(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => true,
    _ => false,
  };
}

/// [DioException] 을 [ApiException] 으로 풀어내는 헬퍼.
///
/// [ErrorInterceptor] 가 미리 [ApiException] 을 `error` 에 심어두므로 보통
/// 그 값을 그대로 반환하고, 없으면 즉석에서 [ApiException.fromDio] 로 변환한다.
extension DioExceptionX on DioException {
  ApiException toApiException() =>
      error is ApiException ? error! as ApiException : ApiException.fromDio(this);
}
