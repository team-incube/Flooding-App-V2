import 'package:dio/dio.dart';

import '../config/env.dart';
import 'auth_interceptor.dart';
import 'dio_client.dart';
import 'error_interceptor.dart';

/// Flooding 백엔드(`Env.apiBaseUrl`) 전용 [Dio] 팩토리.
///
/// baseUrl 을 설정하고 access token 을 Bearer 로 주입한다.
/// [refreshToken]·[onRefresh] 가 주어지면 401 자동 갱신([AuthInterceptor])을,
/// 아니면 단순 Bearer 주입만 부착한다. 토큰 입출력은 콜백으로 주입받아
/// core 가 특정 저장소 구현에 의존하지 않도록 한다.
class FloodingApiClient {
  FloodingApiClient._();

  static Dio create({
    required TokenProvider accessToken,
    TokenProvider? refreshToken,
    TokenRefresher? onRefresh,
    SessionInvalidator? onSessionExpired,
    Dio? dio,
  }) {
    final client = dio ?? DioClient.create();
    client.options.baseUrl = Env.apiBaseUrl;

    if (refreshToken != null && onRefresh != null) {
      client.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: accessToken,
          refreshTokenProvider: refreshToken,
          onRefresh: onRefresh,
          onSessionExpired: onSessionExpired ?? () async {},
          retryClient: client,
        ),
      );
    } else {
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await accessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );
    }

    // 401 재시도 등 인증 처리가 끝난 뒤 마지막으로 에러를 정규화한다.
    client.interceptors.add(ErrorInterceptor());
    return client;
  }
}
