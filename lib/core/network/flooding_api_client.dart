import 'package:dio/dio.dart';

import '../config/env.dart';
import 'auth_interceptor.dart' show TokenProvider;
import 'dio_client.dart';

/// Flooding 백엔드(`Env.apiBaseUrl`) 전용 [Dio] 팩토리.
///
/// baseUrl 을 설정하고, 저장된 access token 을 Bearer 로 주입하는
/// 인터셉터를 붙인다. 토큰 입출력은 콜백([TokenProvider])으로 주입받아
/// core 가 특정 저장소 구현에 의존하지 않도록 한다.
///
/// 401 자동 갱신(refresh)은 Flooding 인증 브릿지가 마련된 뒤 연결한다.
class FloodingApiClient {
  FloodingApiClient._();

  static Dio create({required TokenProvider accessToken, Dio? dio}) {
    final client = dio ?? DioClient.create();
    client.options.baseUrl = Env.apiBaseUrl;
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
    return client;
  }
}
