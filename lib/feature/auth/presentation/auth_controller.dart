import 'package:flutter/foundation.dart';

import '../../../core/config/env.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/pkce.dart';
import '../data/datagsm_auth_service.dart';
import '../data/datasources/token_storage.dart';
import '../data/flooding_auth_service.dart';
import '../data/models/oauth_token.dart';
import '../data/user_service.dart';
import 'pages/oauth_webview_page.dart';

/// 앱 전역 인증 상태.
enum AuthStatus {
  /// 유효한 세션 보유.
  authenticated,

  /// 토큰 없음·로그인 취소·세션 만료.
  unauthenticated,
}

/// 인증 상태를 보관하고 변경 시 리스너에 알리는 컨트롤러.
///
/// go_router 의 `refreshListenable` 로 사용되어, 상태가 바뀌면 redirect 가
/// 재평가되며 login/home 로 자동 전환된다. 세션 만료([AuthInterceptor] 의
/// 갱신 실패) 시에도 [DatagsmAuthService] 에 주입한 콜백으로 상태가 갱신돼
/// 로그인 화면으로 되돌아간다.
class AuthController extends ChangeNotifier {
  AuthController({
    DatagsmAuthService? authService,
    TokenStorage? tokenStorage,
    SessionValidator? sessionValidator,
    FloodingAuthService? floodingAuthService,
  }) : _tokenStorage = tokenStorage ?? TokenStorage() {
    _authService =
        authService ??
        DatagsmAuthService(
          tokenStorage: _tokenStorage,
          onSessionExpired: expireSession,
        );
    _sessionValidator =
        sessionValidator ??
        UserService(
          tokenStorage: _tokenStorage,
          onSessionExpired: expireSession,
        );
    _floodingAuth = floodingAuthService ?? FloodingAuthService();
  }

  final TokenStorage _tokenStorage;
  late final DatagsmAuthService _authService;
  late final SessionValidator _sessionValidator;
  late final FloodingAuthService _floodingAuth;

  // 초기값. 앱 시작 시 runApp 이전에 bootstrap() 으로 실제 상태가 채워진다.
  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  String? _error;

  /// 직전 로그인 시도의 실패 사유. 성공·미시도 시 null.
  String? get error => _error;

  /// 앱 시작 시 1회 호출해 초기 인증 상태를 결정한다.
  ///
  /// 저장된 토큰이 없으면 미인증. 토큰이 있으면 `/users/me` 로 세션 유효성을
  /// 검사해, 401 이면 토큰을 비우고 미인증(로그인 화면)으로 보낸다.
  /// 네트워크 등으로 판단이 불가하면 오프라인 사용자를 막지 않도록 진입을 허용한다.
  Future<void> bootstrap() async {
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) {
      _set(AuthStatus.unauthenticated);
      return;
    }

    final check = await _sessionValidator.validateSession();
    if (check == SessionCheck.unauthorized) {
      await _tokenStorage.clear();
      _set(AuthStatus.unauthenticated);
      return;
    }
    _set(AuthStatus.authenticated);
  }

  /// 웹뷰에 띄울 authorize URL 을 생성한다.
  Uri buildAuthorizeUri(PkcePair pkce) => _authService.buildAuthorizeUri(pkce);

  /// 웹뷰 콜백을 검증하고 토큰 교환·저장까지 마쳐 세션을 확립한다.
  ///
  /// 성공 시 [AuthStatus.authenticated] 로, 취소·실패 시
  /// [AuthStatus.unauthenticated] 로 전환하며 [error] 에 사유를 남긴다.
  Future<void> completeLogin(OAuthCallback? callback, PkcePair pkce) async {
    try {
      if (callback == null) {
        _fail('로그인이 취소되었습니다.');
        return;
      }
      if (!callback.isSuccess) {
        throw AuthException(callback.error ?? '로그인이 취소되었습니다.');
      }
      if (callback.state != pkce.state) {
        throw const AuthException('state 불일치 — 인증 요청이 변조되었을 수 있습니다.');
      }

      // DataGSM 으로 받은 인가 코드를 Flooding 백엔드로 보내 토큰을 발급받는다.
      // (백엔드가 OAuth 코드 교환을 대신 수행하고 자체 토큰을 내려준다.)

      if (callback.code == null) {
        throw const AuthException('authCode가 누락되거나 유효하지 않습니다..');
      }

      final tokens = await _floodingAuth.signin(
        authCode: callback.code!,
        redirectUri: Env.datagsmRedirectUri,
      );
      await _tokenStorage.save(
        OAuthToken(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        ),
      );
      Logger.d('로그인 성공 (Flooding 토큰 발급)', tag: 'AUTH');

      _set(AuthStatus.authenticated);
    } on AuthException catch (e) {
      _fail(e.message);
    } catch (e, s) {
      Logger.e('로그인 처리 중 오류', tag: 'AUTH', error: e, stackTrace: s);
      _fail('로그인 중 문제가 발생했습니다.');
    }
  }

  /// 세션 만료(토큰 갱신 실패) 시 저장 토큰을 비우고 미인증 상태로 되돌린다.
  ///
  /// Flooding 인증 클라이언트의 refresh 실패 콜백으로 연결되어,
  /// 토큰 재발급이 실패하면 즉시 로그인 화면으로 전환된다.
  Future<void> expireSession() async {
    await _tokenStorage.clear();
    _set(AuthStatus.unauthenticated);
  }

  void _set(AuthStatus status) {
    _status = status;
    _error = null;
    notifyListeners();
  }

  void _fail(String message) {
    _error = message;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
