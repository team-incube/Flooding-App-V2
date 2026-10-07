import 'package:dio/dio.dart';

import '../utils/logger.dart';
import '../utils/token_utils.dart';

/// 저장된 토큰을 읽어오는 콜백.
typedef TokenProvider = Future<String?> Function();

/// refresh token 으로 갱신을 수행·저장하고 새 access token 을 반환하는 콜백.
///
/// refresh token 자체가 무효(서버 401)면 [SessionExpiredException] 을 던진다.
/// 그 외 실패(네트워크·5xx·403)는 [DioException] 그대로 던져 원인을 보존한다.
typedef TokenRefresher = Future<String> Function(String refreshToken);

/// 세션 무효화(저장 토큰 제거) 콜백.
typedef SessionInvalidator = Future<void> Function();

/// refresh token 이 무효(서버 401)라 재로그인이 필요함을 알리는 예외.
///
/// [TokenRefresher] 가 이 예외를 던질 때만 [AuthInterceptor] 가 세션을 종료한다.
class SessionExpiredException implements Exception {
  const SessionExpiredException();

  @override
  String toString() => 'SessionExpiredException: refresh token 이 만료되었습니다.';
}

/// 인증이 필요한 요청에 access token 을 주입하고,
/// 401 응답 시 refresh token 으로 갱신 후 1회 재시도하는 제네릭 인터셉터.
///
/// 특정 도메인(DataGSM 등)에 의존하지 않도록 토큰 입출력은 콜백으로 주입받는다.
/// 갱신이 [SessionExpiredException] 으로 실패할 때만 [onSessionExpired] 로 세션을
/// 종료한다. 네트워크·서버 오류·403 은 refresh token 이 아직 유효할 수 있으므로
/// 토큰을 지우지 않고 그 에러를 요청의 에러로 넘긴다.
///
/// 동시에 여러 요청이 401 을 받아도 갱신은 single-flight 로 1회만 수행한다 —
/// 진행 중인 refresh [Future] 를 공유해 후속 요청은 그 결과를 기다린 뒤 재시도한다.
/// 이는 refresh token 회전(rotation) 시 옛 토큰으로 중복 갱신해 실패하는 것을 막는다.
class AuthInterceptor extends Interceptor {
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

  /// 진행 중인 갱신 작업. null 이 아니면 이미 갱신이 진행 중이다(single-flight).
  Future<String>? _refreshing;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var accessToken = await _accessTokenProvider();

    // 만료된 걸 로컬에서 미리 알 수 있으면, 401을 기다렸다가 갱신하는 대신
    // 요청 전에 먼저 갱신해 왕복 한 번을 줄인다.
    if (accessToken != null && TokenUtils.isExpired(accessToken)) {
      final refreshToken = await _refreshTokenProvider();
      if (refreshToken != null) {
        try {
          accessToken = await _refreshOnce(refreshToken);
        } on SessionExpiredException {
          Logger.e('요청 전 토큰 선제 갱신 실패(refresh 만료) — 세션 종료', tag: 'AUTH');
          await _onSessionExpired();
          // 401 로 거절해, 호출부(세션 검사 등)가 세션 만료로 판단하게 한다.
          return handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 401),
              type: DioExceptionType.badResponse,
              error: '인증 토큰 갱신에 실패했습니다.',
            ),
          );
        } catch (e) {
          Logger.e('요청 전 토큰 선제 갱신 실패 — 토큰 유지', tag: 'AUTH', error: e);
          // 뒤 인터셉터(ErrorInterceptor)까지 흘려 네트워크 오류 처리 등을 태운다.
          return handler.reject(_toRequestError(e, options), true);
        }
      }
    }

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
      await _onSessionExpired();
      return handler.next(err);
    }

    final String newAccessToken;
    try {
      newAccessToken = await _refreshOnce(refreshToken);
    } on SessionExpiredException {
      Logger.e('토큰 갱신 실패(refresh 만료) — 세션 종료', tag: 'AUTH');
      await _onSessionExpired();
      return handler.next(err);
    } catch (e) {
      // 원래의 401 을 넘기면 호출부가 세션 만료로 오인하므로 갱신 실패 원인을 넘긴다.
      Logger.e('토큰 갱신 실패 — 토큰 유지', tag: 'AUTH', error: e);
      return handler.next(_toRequestError(e, err.requestOptions));
    }

    final retryOptions = err.requestOptions
      ..extra[_retriedFlag] = true
      ..headers['Authorization'] = 'Bearer $newAccessToken';
    try {
      final response = await _retryClient.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // 갱신은 성공했으므로 재시도 실패는 세션과 무관하다 — 그 에러를 그대로 넘긴다.
      return handler.next(e);
    }
  }

  /// 갱신 실패 원인을 원래 요청의 [DioException] 으로 바꾼다.
  ///
  /// 상태 코드·응답 본문·에러 타입을 보존해, 403 은 권한 오류로, 연결 실패는
  /// 네트워크 오류로 정규화되게 한다.
  static DioException _toRequestError(Object error, RequestOptions options) {
    if (error is DioException) return error.copyWith(requestOptions: options);
    return DioException(requestOptions: options, error: error);
  }

  /// 갱신을 single-flight 로 수행한다.
  ///
  /// 이미 진행 중인 갱신이 있으면 그 [Future] 를 그대로 반환해 동시 요청이
  /// 동일한 refresh 결과를 공유하도록 한다. 완료(성공/실패) 시 캐시를 비워
  /// 다음 만료 때 다시 갱신할 수 있게 한다.
  Future<String> _refreshOnce(String refreshToken) {
    return _refreshing ??=
        _onRefresh(refreshToken).whenComplete(() => _refreshing = null);
  }
}
