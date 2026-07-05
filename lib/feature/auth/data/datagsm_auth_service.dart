import 'package:dio/dio.dart';
import 'package:retrofit/call_adapter.dart';

import '../../../core/config/env.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/pkce.dart';
import 'datasources/datagsm_auth_api.dart';
import 'models/oauth_token.dart';
import 'models/refresh_request.dart';
import 'models/token_request.dart';
import 'datasources/token_storage.dart';

/// 인증 흐름 중 발생한 오류.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// DataGSM OAuth(PKCE) 흐름을 담당하는 서비스.
///
/// authorize URL 생성 → code 교환 → token 갱신 → userinfo 조회.
/// 리소스 요청은 [AuthInterceptor] 가 access token 주입 및 401 자동 갱신을 처리한다.
class DatagsmAuthService {
  DatagsmAuthService._(this._authApi);

  factory DatagsmAuthService({
    Dio? authDio,
    Dio? resourceDio,
    TokenStorage? tokenStorage,
    SessionInvalidator? onSessionExpired,
  }) {
    final storage = tokenStorage ?? TokenStorage();

    // 인증(token) 서버용 — 인터셉터를 붙이지 않아 갱신 무한루프를 방지한다.
    final authApi = DatagsmAuthApi(
      authDio ?? DioClient.create(),
      baseUrl: _authorizationBase,
    );

    // 리소스 서버용 — bearer 주입 + 401 자동 갱신 인터셉터를 부착한다.
    final resourceClient = resourceDio ?? DioClient.create();
    resourceClient.interceptors.add(
      AuthInterceptor(
        accessTokenProvider: storage.readAccessToken,
        refreshTokenProvider: storage.readRefreshToken,
        // 세션 만료 시 토큰 제거는 기본 동작이고, 주입 시 인증 상태 갱신 등
        // 추가 처리(예: 로그인 화면 전환)를 위임할 수 있다.
        onSessionExpired: onSessionExpired ?? storage.clear,
        retryClient: resourceClient,
        onRefresh: (refreshToken) async {
          final token = await _refresh(authApi, refreshToken);
          // refresh 시 refresh_token 까지 회전 발급되므로 둘 다 갱신 저장.
          await storage.save(token);
          return token.accessToken;
        },
      ),
    );
    return DatagsmAuthService._(authApi);
  }

  final DatagsmAuthApi _authApi;
  static const String _authorizationHost = 'oauth.authorization.datagsm.kr';
  static const String _authorizationBase =
      'https://oauth.authorization.datagsm.kr';

  /// 웹뷰에 띄울 authorize URL 을 생성한다.
  ///
  /// 코드 교환은 Flooding 백엔드(`/auth/signin`)가 confidential 클라이언트로
  /// 수행하므로, 앱은 PKCE(`code_challenge`)를 보내지 않는다. (PKCE 를 붙이면
  /// 백엔드가 `code_verifier` 없이 교환하다 DataGSM 에 거부당한다.)
  /// [pkce] 의 `state` 만 CSRF 방지용으로 사용한다.
  Uri buildAuthorizeUri(PkcePair pkce, {String? scope}) {
    return Uri.https(_authorizationHost, '/v1/oauth/authorize', {
      'client_id': Env.datagsmClientId,
      'redirect_uri': Env.datagsmRedirectUri,
      'response_type': 'code',
      'state': pkce.state,
      if (scope != null && scope.isNotEmpty) 'scope': scope,
    });
  }

  /// authorization code 를 access/refresh 토큰으로 교환한다.
  Future<OAuthToken> exchangeCode({
    required String code,
    required String codeVerifier,
  }) async {
    try {
      return await _authApi.exchangeToken(
        TokenRequest(
          code: code,
          clientId: Env.datagsmClientId,
          redirectUri: Env.datagsmRedirectUri,
          codeVerifier: codeVerifier,
        ),
      );
    } on DioException catch (e) {
      Logger.e(
        'token 교환 실패: ${e.response?.statusCode} ${e.response?.data}',
        tag: 'AUTH',
        error: e,
      );
      throw const AuthException('토큰 교환에 실패했습니다.');
    }
  }

  /// refresh token 으로 새 access/refresh 토큰을 발급한다.
  Future<OAuthToken> refresh(String refreshToken) =>
      _refresh(_authApi, refreshToken);

  static Future<OAuthToken> _refresh(
    DatagsmAuthApi authApi,
    String refreshToken,
  ) async {
    try {
      return await authApi.refreshToken(
        RefreshRequest(
          refreshToken: refreshToken,
          clientId: Env.datagsmClientId,
        ),
      );
    } on DioException catch (e) {
      Logger.e(
        'token 갱신 실패: ${e.response?.statusCode} ${e.response?.data}',
        tag: 'AUTH',
        error: e,
      );
      throw const AuthException('세션이 만료되었습니다. 다시 로그인해 주세요.');
    }
  }
}
