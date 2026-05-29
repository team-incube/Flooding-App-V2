import 'package:dio/dio.dart';

import '../utils/logger.dart';

/// 저장된 토큰을 읽어오는 콜백.
typedef TokenProvider = Future<String?> Function();

/// refresh token 으로 갱신을 수행·저장하고 새 access token 을 반환하는 콜백.
typedef TokenRefresher = Future<String> Function(String refreshToken);

/// 세션 무효화(저장 토큰 제거) 콜백.
typedef SessionInvalidator = Future<void> Function();

/// 인증이 필요한 요청에 access token 을 주입하고,
/// 401 응답 시 refresh token 으로 갱신 후 1회 재시도하는 제네릭 인터셉터.
///
/// 특정 도메인(DataGSM 등)에 의존하지 않도록 토큰 입출력은 콜백으로 주입받는다.
/// 갱신이 실패하면 [onSessionExpired] 로 세션을 종료한다.
/// 동시 401 을 직렬화하기 위해 [QueuedInterceptor] 를 사용한다.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenProvider accessTokenProvider,
    required TokenProvider refreshTokenProvider,
    required TokenRefresher onRefresh,
    required SessionInvalidator onSessionExpired,
    required Dio retryClient,
  })  : _accessTokenProvider = accessTokenProvider,
        _refreshTokenProvider = refreshTokenProvider,
        _onRefresh = onRefresh,
        _onSessionExpired = onSessionExpired,
        _retryClient = retryClient;

  final TokenProvider _accessTokenProvider;
  final TokenProvider _refreshTokenProvider;
  final TokenRefresher _onRefresh;
  final SessionInvalidator _onSessionExpired;
  final Dio _retryClient;

  static const String _retriedFlag = 'auth_retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _accessTokenProvider();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;
    if (!isUnauthorized || alreadyRetried) {
      return handler.next(err);
    }

    final refreshToken = await _refreshTokenProvider();
    if (refreshToken == null) {
      return handler.next(err);
    }

    try {
      final newAccessToken = await _onRefresh(refreshToken);

      final retryOptions = err.requestOptions
        ..extra[_retriedFlag] = true
        ..headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await _retryClient.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } catch (e) {
      Logger.e('토큰 갱신 실패 — 세션 종료', tag: 'AUTH', error: e);
      await _onSessionExpired();
      return handler.next(err);
    }
  }
}
