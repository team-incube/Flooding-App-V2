import 'datasources/token_storage.dart';
import 'flooding_auth_service.dart';
import 'models/oauth_token.dart';

/// 앱 전역에서 refresh token 갱신을 single-flight 로 조율한다.
///
/// [FloodingAuthedClient.create] 는 저장소·서비스별로 별도의 [Dio] 인스턴스를
/// 만들며, 각 인스턴스의 [AuthInterceptor]는 자기 자신의 갱신 작업만 안다.
/// 이 클래스를 모든 인스턴스가 공유하면, 여러 API 호출이 동시에 401 을 받아도
/// 갱신은 앱 전체에서 1회만 수행되어 회전(rotation)된 refresh token 을
/// 옛 토큰으로 중복 갱신해 실패하는 경쟁 상태를 막는다.
class SharedTokenRefresher {
  SharedTokenRefresher({TokenStorage? tokenStorage, FloodingAuthService? authService})
    : _storage = tokenStorage ?? TokenStorage(),
      _auth = authService ?? FloodingAuthService();

  final TokenStorage _storage;
  final FloodingAuthService _auth;

  Future<String>? _refreshing;

  Future<String> refresh(String refreshToken) {
    return _refreshing ??= _performRefresh(
      refreshToken,
    ).whenComplete(() => _refreshing = null);
  }

  Future<String> _performRefresh(String refreshToken) async {
    final tokens = await _auth.reissue(refreshToken: refreshToken);
    await _storage.save(
      OAuthToken(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      ),
    );
    return tokens.accessToken;
  }
}

/// 앱 전역에서 공유하는 기본 인스턴스.
///
/// [FloodingAuthedClient.create] 의 모든 호출부가 별도 인자 없이 이 인스턴스를
/// 공유해, 별도 배선 없이도 갱신이 앱 전체에서 조율되게 한다.
final defaultSharedTokenRefresher = SharedTokenRefresher();
