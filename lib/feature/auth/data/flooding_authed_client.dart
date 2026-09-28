import 'package:dio/dio.dart';

import '../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import '../../../core/network/flooding_api_client.dart';
import 'datasources/token_storage.dart';
import 'flooding_auth_service.dart';
import 'shared_token_refresher.dart';

/// 인증이 필요한 Flooding 백엔드 호출용 [Dio] 팩토리.
///
/// 저장된 access token 을 주입하고, 401 시 `/auth/reissue` 로 토큰을 갱신해
/// 1회 재시도한다. 갱신 실패 시 [onSessionExpired](기본: 토큰 삭제)로 세션을 종료한다.
///
/// 갱신은 기본적으로 [defaultSharedTokenRefresher] 를 통해 앱 전역에서
/// single-flight 로 조율된다 — 호출부마다 별도의 [Dio] 인스턴스를 만들더라도
/// 동시에 여러 요청이 401 을 받았을 때 갱신이 중복 수행되지 않는다.
class FloodingAuthedClient {
  FloodingAuthedClient._();

  static Dio create({
    TokenStorage? tokenStorage,
    FloodingAuthService? authService,
    SharedTokenRefresher? refresher,
    SessionInvalidator? onSessionExpired,
    Dio? dio,
  }) {
    final storage = tokenStorage ?? TokenStorage();
    final tokenRefresher =
        refresher ??
        ((tokenStorage != null || authService != null)
            ? SharedTokenRefresher(tokenStorage: storage, authService: authService)
            : defaultSharedTokenRefresher);

    return FloodingApiClient.create(
      accessToken: storage.readAccessToken,
      refreshToken: storage.readRefreshToken,
      onRefresh: tokenRefresher.refresh,
      onSessionExpired: onSessionExpired ?? storage.clear,
      dio: dio,
    );
  }
}
