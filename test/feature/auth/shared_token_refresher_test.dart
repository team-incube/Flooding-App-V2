import 'package:flooding_v2/core/network/auth_interceptor.dart'
    show SessionExpiredException;
import 'package:flooding_v2/feature/auth/data/datasources/token_storage.dart';
import 'package:flooding_v2/feature/auth/data/flooding_auth_service.dart';
import 'package:flooding_v2/feature/auth/data/models/oauth_token.dart';
import 'package:flooding_v2/feature/auth/data/models/signin_response.dart';
import 'package:flooding_v2/feature/auth/data/shared_token_refresher.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;

  @override
  Future<void> save(OAuthToken token) async {
    accessToken = token.accessToken;
    refreshToken = token.refreshToken;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;
}

/// refresh token 을 회전시키는 서버를 흉내 낸다 — 현재 유효한 refresh token 만
/// 재발급을 허용하고, 그 외(이미 회전된 옛 토큰)는 401 로 거절한다.
class _RotatingAuthService extends FloodingAuthService {
  _RotatingAuthService(this.validRefreshToken);

  String validRefreshToken;
  int calls = 0;

  @override
  Future<SigninData> reissue({required String refreshToken}) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (refreshToken != validRefreshToken) {
      throw const SessionExpiredException();
    }
    validRefreshToken = 'RT$calls';
    return SigninData(accessToken: 'AT$calls', refreshToken: validRefreshToken);
  }
}

void main() {
  group('SharedTokenRefresher', () {
    test('인스턴스가 달라도 같은 refresh token 의 동시 갱신은 1회만 수행한다', () async {
      final storage = _FakeTokenStorage(accessToken: 'AT0', refreshToken: 'RT0');
      final auth = _RotatingAuthService('RT0');
      // 저장소(Study·Massage 등)마다 따로 생기는 인스턴스를 흉내 낸다.
      final a = SharedTokenRefresher(tokenStorage: storage, authService: auth);
      final b = SharedTokenRefresher(tokenStorage: storage, authService: auth);
      final c = SharedTokenRefresher(tokenStorage: storage, authService: auth);

      final results = await Future.wait([
        a.refresh('RT0'),
        b.refresh('RT0'),
        c.refresh('RT0'),
      ]);

      expect(auth.calls, 1);
      expect(results, everyElement('AT1'));
      expect(storage.refreshToken, 'RT1');
    });

    test('다른 요청이 이미 회전시킨 옛 refresh token 이면 재발급 없이 저장된 토큰을 쓴다', () async {
      final storage = _FakeTokenStorage(accessToken: 'AT0', refreshToken: 'RT0');
      final auth = _RotatingAuthService('RT0');
      final first = SharedTokenRefresher(tokenStorage: storage, authService: auth);
      final stale = SharedTokenRefresher(tokenStorage: storage, authService: auth);

      await first.refresh('RT0');
      // 갱신 전에 RT0 를 읽어 둔 요청이 뒤늦게 갱신을 요청하는 경우.
      final token = await stale.refresh('RT0');

      expect(auth.calls, 1);
      expect(token, 'AT1');
    });

    test('갱신이 실패하면 에러를 전달하고, 다음 호출은 다시 재발급을 시도한다', () async {
      final storage = _FakeTokenStorage(accessToken: 'AT0', refreshToken: 'RT0');
      final auth = _RotatingAuthService('other');
      final refresher = SharedTokenRefresher(
        tokenStorage: storage,
        authService: auth,
      );

      await expectLater(
        refresher.refresh('RT0'),
        throwsA(isA<SessionExpiredException>()),
      );
      await expectLater(
        refresher.refresh('RT0'),
        throwsA(isA<SessionExpiredException>()),
      );

      expect(auth.calls, 2);
    });
  });
}
