import 'package:flutter/material.dart';

import '../../../../core/config/env.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/text_style/app_font.dart';
import '../../../../core/utils/pkce.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../auth_controller.dart';
import 'oauth_webview_page.dart';

/// DataGSM OAuth 로그인 화면.
///
/// 진입 시 별도 버튼 없이 곧장 인증 웹뷰를 띄우고, 취소·실패하면 재시도
/// 화면을 보여준다. 토큰 교환·상태 전환은 [AuthController] 가 담당한다.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final AuthController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    // 진입 즉시 자동으로 로그인 흐름을 시작한다(저장 토큰이 없을 때 도달).
    WidgetsBinding.instance.addPostFrameCallback((_) => _login());
  }

  /// PKCE 생성 → 웹뷰로 authorize → 콜백을 컨트롤러에 넘겨 세션을 확립한다.
  Future<void> _login() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);

    final pkce = Pkce.generate();
    final authorizeUri = widget.controller.buildAuthorizeUri(pkce);

    final callback = await Navigator.of(context).push<OAuthCallback>(
      MaterialPageRoute(
        builder: (_) => OAuthWebViewPage(
          authorizeUri: authorizeUri,
          redirectUri: Env.datagsmRedirectUri,
        ),
      ),
    );

    await widget.controller.completeLogin(callback, pkce);
    if (mounted) setState(() => _authenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticating) {
      return const Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.lightP1),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.controller.error ?? '로그인이 필요합니다.',
              textAlign: TextAlign.center,
              style: AppFont.text2.copyWith(color: AppColors.lightSub1),
            ),
            const SizedBox(height: AppSpacing.s24),
            PrimaryActionButton(
              label: '다시 로그인',
              expand: true,
              onPressed: _login,
            ),
          ],
        ),
      ),
    );
  }
}
