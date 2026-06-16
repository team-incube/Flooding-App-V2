import 'package:dio/dio.dart';

import '../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import '../../../core/network/flooding_api_client.dart';
import 'datasources/token_storage.dart';
import 'flooding_auth_service.dart';
import 'models/oauth_token.dart';

/// 인증이 필요한 Flooding 백엔드 호출용 [Dio] 팩토리.
///
/// 저장된 access token 을 주입하고, 401 시 `/auth/reissue` 로 토큰을 갱신해
/// 1회 재시도한다. 갱신 실패 시 [onSessionExpired](기본: 토큰 삭제)로 세션을 종료한다.
class FloodingAuthedClient {
  FloodingAuthedClient._();

  static Dio create({
    TokenStorage? tokenStorage,
    FloodingAuthService? authService,
    SessionInvalidator? onSessionExpired,
    Dio? dio,
  }) {
    final storage = tokenStorage ?? TokenStorage();
    final auth = authService ?? FloodingAuthService();

    return FloodingApiClient.create(
      accessToken: storage.readAccessToken,
      refreshToken: storage.readRefreshToken,
      onRefresh: (refreshToken) async {
        final tokens = await auth.reissue(refreshToken: refreshToken);
        // reissue 시 refresh token 도 회전 발급되므로 둘 다 저장한다.
        await storage.save(
          OAuthToken(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          ),
        );
        return tokens.accessToken;
      },
      onSessionExpired: onSessionExpired ?? storage.clear,
      dio: dio,
    );
  }
}
