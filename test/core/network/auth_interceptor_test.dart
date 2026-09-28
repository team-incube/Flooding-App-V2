import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flooding_v2/core/network/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _body(int statusCode) {
  return ResponseBody.fromString(
    '{}',
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('AuthInterceptor', () {
    late Dio dio;
    late List<String> events;

    setUp(() {
      events = [];
    });

    test('onRequest 는 access token 을 Authorization 헤더로 붙인다', () async {
      String? sentAuth;
      dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) {
          sentAuth = options.headers['Authorization'] as String?;
          return _body(200);
        });
      dio.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: () async => 'valid-token',
          refreshTokenProvider: () async => 'refresh-token',
          onRefresh: (_) async => 'new-token',
          onSessionExpired: () async => events.add('expired'),
          retryClient: dio,
        ),
      );

      await dio.get<dynamic>('/ping');

      expect(sentAuth, 'Bearer valid-token');
    });

    test('401 + refresh 성공 시 새 토큰으로 재시도해 성공한다', () async {
      var currentAccessToken = 'expired-token';
      dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) {
          final auth = options.headers['Authorization'];
          return _body(auth == 'Bearer new-token' ? 200 : 401);
        });
      dio.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: () async => currentAccessToken,
          refreshTokenProvider: () async => 'refresh-token',
          onRefresh: (token) async {
            events.add('refresh:$token');
            currentAccessToken = 'new-token';
            return currentAccessToken;
          },
          onSessionExpired: () async => events.add('expired'),
          retryClient: dio,
        ),
      );

      final response = await dio.get<dynamic>('/ping');

      expect(response.statusCode, 200);
      expect(events, ['refresh:refresh-token']);
    });

    test('401 인데 refresh token 이 없으면 세션을 종료한다', () async {
      dio = Dio()..httpClientAdapter = _FakeAdapter((options) => _body(401));
      dio.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: () async => 'expired-token',
          refreshTokenProvider: () async => null,
          onRefresh: (_) async {
            fail('refresh token 이 없는데 갱신이 호출되면 안 된다');
          },
          onSessionExpired: () async => events.add('expired'),
          retryClient: dio,
        ),
      );

      await expectLater(dio.get<dynamic>('/ping'), throwsA(isA<DioException>()));

      expect(events, ['expired']);
    });

    test('401 + refresh 실패 시 세션을 종료한다', () async {
      dio = Dio()..httpClientAdapter = _FakeAdapter((options) => _body(401));
      dio.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: () async => 'expired-token',
          refreshTokenProvider: () async => 'refresh-token',
          onRefresh: (_) async => throw Exception('refresh 실패'),
          onSessionExpired: () async => events.add('expired'),
          retryClient: dio,
        ),
      );

      await expectLater(dio.get<dynamic>('/ping'), throwsA(isA<DioException>()));

      expect(events, ['expired']);
    });

    test('동시에 여러 요청이 401 을 받아도 갱신은 1회만 수행한다(single-flight)', () async {
      var currentAccessToken = 'expired-token';
      var refreshCalls = 0;
      dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) {
          final auth = options.headers['Authorization'];
          return _body(auth == 'Bearer new-token' ? 200 : 401);
        });
      dio.interceptors.add(
        AuthInterceptor(
          accessTokenProvider: () async => currentAccessToken,
          refreshTokenProvider: () async => 'refresh-token',
          onRefresh: (_) async {
            refreshCalls++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            currentAccessToken = 'new-token';
            return currentAccessToken;
          },
          onSessionExpired: () async => events.add('expired'),
          retryClient: dio,
        ),
      );

      final results = await Future.wait([
        dio.get<dynamic>('/a'),
        dio.get<dynamic>('/b'),
        dio.get<dynamic>('/c'),
      ]);

      expect(refreshCalls, 1);
      expect(results.map((r) => r.statusCode), everyElement(200));
    });
  });
}
