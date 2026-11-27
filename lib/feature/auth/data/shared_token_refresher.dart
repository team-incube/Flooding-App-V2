import 'datasources/token_storage.dart';
import 'flooding_auth_service.dart';
import 'models/oauth_token.dart';

/// 앱 전역에서 refresh token 갱신을 single-flight 로 조율한다.
///
/// [FloodingAuthedClient.create] 는 저장소·서비스별로 별도의 [Dio] 인스턴스를
/// 만들며, 각 인스턴스의 [AuthInterceptor]는 자기 자신의 갱신 작업만 안다.
/// 여러 API 호출이 동시에 401 을 받아도 같은 refresh token 의 재발급은 앱 전체에서
/// 1회만 수행되어, 회전(rotation)된 refresh token 을 옛 토큰으로 중복 갱신해
/// 실패(세션 종료)하는 경쟁 상태를 막는다.
///
/// 저장소마다 이 클래스의 인스턴스가 따로 생겨도 조율되도록, 진행 중인 갱신은
/// 인스턴스가 아니라 refresh token 별로 전역([_inFlight])에 보관한다.
class SharedTokenRefresher {
  SharedTokenRefresher({TokenStorage? tokenStorage, FloodingAuthService? authService})
    : _storage = tokenStorage ?? TokenStorage(),
      _auth = authService ?? FloodingAuthService();

  final TokenStorage _storage;
  final FloodingAuthService _auth;

  /// refresh token 별로 진행 중인 갱신. 모든 인스턴스가 공유한다.
  static final Map<String, Future<String>> _inFlight = {};

  Future<String> refresh(String refreshToken) {
    // whenComplete 콜백이 Future 를 반환하면 그걸 기다리므로, 자기 자신(제거된
    // Future)을 기다리는 교착을 피하려고 블록 본문으로 아무것도 반환하지 않는다.
    return _inFlight[refreshToken] ??= _performRefresh(
      refreshToken,
    ).whenComplete(() {
      _inFlight.remove(refreshToken);
    });
  }

  Future<String> _performRefresh(String refreshToken) async {
    // 이 요청이 옛 refresh token 을 읽은 사이 다른 요청이 이미 갱신(회전)을
    // 끝냈다면, 옛 토큰으로 재발급(401 → 세션 종료)하지 않고 그 결과를 쓴다.
    final storedRefreshToken = await _storage.readRefreshToken();
    if (storedRefreshToken != null && storedRefreshToken != refreshToken) {
      final storedAccessToken = await _storage.readAccessToken();
      if (storedAccessToken != null) return storedAccessToken;
    }

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
