import 'package:dio/dio.dart';

import '../../feature/auth/data/datasources/token_storage.dart';
import '../../feature/auth/data/flooding_authed_client.dart';
import 'auth_interceptor.dart' show SessionInvalidator;

/// SSE(장시간 스트리밍) 전용 인증 [Dio] 팩토리.
///
/// 일반 REST 클라이언트([FloodingAuthedClient])와 나뉘는 점:
/// - 수신 타임아웃을 비활성화([Duration.zero])해 스트림이 몇 초 뒤 끊기지 않게 한다.
/// - 응답 본문을 통째로 로깅하려는 `LoggingInterceptor` 를 붙이지 않는다 —
///   스트림 본문은 로깅에 의미가 없고, 재연결마다 노이즈만 남기 때문이다.
///   (자체 [Dio] 를 넘겨 [FloodingAuthedClient] 가 로깅 인터셉터를 추가하지
///   않도록 한다.)
///
/// access token 주입과 401 재발급은 REST 와 동일하게 적용한다 — 만료 토큰이면
/// 재연결만 무한 반복하므로 SSE 에도 재발급이 필요하다.
class FloodingSseClient {
  FloodingSseClient._();

  static Dio create({
    TokenStorage? tokenStorage,
    SessionInvalidator? onSessionExpired,
  }) {
    final storage = tokenStorage ?? TokenStorage();
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        // SSE 는 장시간 수신하므로 수신 타임아웃을 두지 않는다.
        receiveTimeout: Duration.zero,
      ),
    );
    return FloodingAuthedClient.create(
      tokenStorage: storage,
      onSessionExpired: onSessionExpired,
      dio: dio,
    );
  }
}
