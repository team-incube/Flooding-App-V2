import 'package:flutter/material.dart';

import '../../../../core/config/env.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/text_style/app_font.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/pkce.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../data/datagsm_auth_service.dart';
import '../../data/datasources/token_storage.dart';
import 'oauth_webview_page.dart';

/// 인증 진행 상태.
enum _AuthStatus { checking, authenticating, authenticated, failed }

/// 앱 시작 시 토큰 유무를 확인해 인증 흐름을 진행한다.
///
/// 저장된 토큰이 있으면 곧장 홈으로 진입하고, 없으면 별도 로그인 화면 없이
/// DataGSM OAuth 웹뷰를 띄운다. 인증에 실패·취소되면 재시도 화면을 보여준다.
class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    this.authService,
    this.tokenStorage,
  });

  /// 테스트 주입용. 미지정 시 기본 구현을 생성한다.
  final DatagsmAuthService? authService;
  final TokenStorage? tokenStorage;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final DatagsmAuthService _authService =
      widget.authService ?? DatagsmAuthService();
  late final TokenStorage _tokenStorage = widget.tokenStorage ?? TokenStorage();

  _AuthStatus _status = _AuthStatus.checking;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// 저장된 토큰이 있으면 홈으로, 없으면 로그인 흐름을 시작한다.
  Future<void> _bootstrap() async {
    if (await _tokenStorage.hasToken()) {
      _setStatus(_AuthStatus.authenticated);
      return;
    }
    await _login();
  }

  Future<void> _login() async {
    _setStatus(_AuthStatus.authenticating);
    try {
      final pkce = Pkce.generate();
      final authorizeUri = _authService.buildAuthorizeUri(pkce);

      if (!mounted) return;
      final callback = await Navigator.of(context).push<OAuthCallback>(
        MaterialPageRoute(
          builder: (_) => OAuthWebViewPage(
            authorizeUri: authorizeUri,
            redirectUri: Env.datagsmRedirectUri,
          ),
        ),
      );

      // 사용자가 로그인 창을 닫음.
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

      _setStatus(_AuthStatus.authenticated);
    } on AuthException catch (e) {
      _fail(e.message);
    } catch (e, s) {
      Logger.e('로그인 처리 중 오류', tag: 'AUTH', error: e, stackTrace: s);
      _fail('로그인 중 문제가 발생했습니다.');
    }
  }

  void _setStatus(_AuthStatus status) {
    if (!mounted) return;
    setState(() {
      _status = status;
      _error = null;
    });
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _status = _AuthStatus.failed;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _AuthStatus.authenticated:
        return const HomePage();
      case _AuthStatus.failed:
        return _AuthRetryView(message: _error, onRetry: _login);
      case _AuthStatus.checking:
      case _AuthStatus.authenticating:
        return const _AuthLoadingView();
    }
  }
}

/// 토큰 확인·인증 진행 중 표시하는 로딩 화면.
class _AuthLoadingView extends StatelessWidget {
  const _AuthLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.lightP1),
      ),
    );
  }
}

/// 인증 실패·취소 시 재시도를 제공하는 화면.
class _AuthRetryView extends StatelessWidget {
  const _AuthRetryView({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message ?? '로그인이 필요합니다.',
              textAlign: TextAlign.center,
              style: AppFont.text2.copyWith(color: AppColors.lightSub1),
            ),
            const SizedBox(height: AppSpacing.s24),
            PrimaryActionButton(
              label: '다시 로그인',
              expand: true,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
