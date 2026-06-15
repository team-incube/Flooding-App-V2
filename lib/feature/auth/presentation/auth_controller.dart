import 'package:flutter/foundation.dart';

import '../../../core/utils/logger.dart';
import '../../../core/utils/pkce.dart';
import '../data/datagsm_auth_service.dart';
import '../data/datasources/token_storage.dart';
import 'blocs/user_cubit.dart';
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
    UserCubit? userCubit,
  }) : _tokenStorage = tokenStorage ?? TokenStorage(),
       _userCubit = userCubit ?? UserCubit() {
    _authService =
        authService ??
        DatagsmAuthService(
          tokenStorage: _tokenStorage,
          onSessionExpired: _onSessionExpired,
        );
  }

  final TokenStorage _tokenStorage;
  final UserCubit _userCubit;
  late final DatagsmAuthService _authService;

  /// 현재 로그인 사용자 정보(이름·학번·역할)를 보관하는 cubit.
  UserCubit get userCubit => _userCubit;

  // 초기값. 앱 시작 시 runApp 이전에 bootstrap() 으로 실제 상태가 채워진다.
  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  String? _error;

  /// 직전 로그인 시도의 실패 사유. 성공·미시도 시 null.
  String? get error => _error;

  /// 저장된 토큰 유무로 초기 상태를 결정한다. 앱 시작 시 1회 호출.
  Future<void> bootstrap() async {
    final hasToken = await _tokenStorage.hasToken();
    _set(hasToken ? AuthStatus.authenticated : AuthStatus.unauthenticated);
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

      final token = await _authService.exchangeCode(
        code: callback.code!,
        codeVerifier: pkce.verifier,
      );
      await _tokenStorage.save(token);

      final user = await _authService.fetchUserInfo();
      Logger.d('로그인 성공: ${user.email}', tag: 'AUTH');
      _userCubit.setUser(user);

      _set(AuthStatus.authenticated);
    } on AuthException catch (e) {
      _fail(e.message);
    } catch (e, s) {
      Logger.e('로그인 처리 중 오류', tag: 'AUTH', error: e, stackTrace: s);
      _fail('로그인 중 문제가 발생했습니다.');
    }
  }

  /// 세션 만료(토큰 갱신 실패) 시 저장 토큰을 비우고 미인증 상태로 되돌린다.
  Future<void> _onSessionExpired() async {
    await _tokenStorage.clear();
    _userCubit.clear();
    _set(AuthStatus.unauthenticated);
  }

  void _set(AuthStatus status) {
    _status = status;
    _error = null;
    notifyListeners();
  }

  void _fail(String message) {
    _userCubit.clear();
    _error = message;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _userCubit.close();
    super.dispose();
  }
}
