import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'network_error_reporter.dart';

/// 모든 [DioException] 을 [ApiException] 으로 정규화해 `error` 에 심는 인터셉터.
///
/// 상태 코드·타임아웃 판정·서버 메시지 추출을 여기서 한 번만 수행하므로,
/// 각 레포지토리는 `DioException` 을 잡아 [DioExceptionX.toApiException] 으로
/// 풀어내기만 하면 된다. 에러를 소비하지 않고 그대로 흘려보내므로
/// (`handler.next`) [AuthInterceptor] 의 401 재시도 등 다른 처리와 공존한다.
///
/// 네트워크 오류(연결 실패·타임아웃)는 추가로 [NetworkErrorReporter] 로 알려,
/// 어느 화면에서든 끊기면 로그인 화면으로 보내는 전역 처리가 동작하게 한다.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = err.error is ApiException
        ? err.error! as ApiException
        : ApiException.fromDio(err);
    if (apiException.isNetwork) NetworkErrorReporter.report();
    if (err.error is ApiException) return handler.next(err);
    handler.next(err.copyWith(error: apiException));
  }
}
