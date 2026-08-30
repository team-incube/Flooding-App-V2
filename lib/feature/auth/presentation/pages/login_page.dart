import 'package:flutter/material.dart';

import '../../../../core/config/env.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/utils/pkce.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
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
  // 진입 즉시 자동 로그인을 시작하므로 첫 프레임부터 스피너를 보여준다
  // (false 로 두면 첫 빌드에서 idle UI 가 한 프레임 깜빡인다).
  bool _authenticating = true;

  @override
  void initState() {
    super.initState();
    // 진입 즉시 자동으로 로그인 흐름을 시작한다(저장 토큰이 없을 때 도달).
    // 첫 프레임부터 _authenticating 이 true 이므로 중복 가드를 우회한다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _login(initial: true));
  }

  /// PKCE 생성 → 웹뷰로 authorize → 콜백을 컨트롤러에 넘겨 세션을 확립한다.
  ///
  /// [initial] 은 진입 직후 자동 로그인 1회용 — 이미 true 인 [_authenticating]
  /// 가드에 막히지 않도록 우회한다. '다시 로그인' 버튼은 [initial] 없이 호출돼
  /// 진행 중 중복 진입을 막는다.
  Future<void> _login({bool initial = false}) async {
    if (!initial) {
      if (_authenticating) return;
      setState(() => _authenticating = true);
    }

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
    // 성공 시에는 redirect 가 홈으로 화면을 교체할 때까지 스피너를 유지한다.
    // 여기서 _authenticating 을 false 로 되돌리면 홈 전환 직전 한 프레임 동안
    // idle 상태('로그인이 필요합니다' + '다시 로그인')가 깜빡인다.
    // 실패·취소(미인증)일 때만 재시도 화면을 보여준다.
    if (mounted && widget.controller.status != AuthStatus.authenticated) {
      setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticating) {
      return const Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(child: AppLoadingIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.controller.error ?? '로그인이 필요합니다.',
                textAlign: TextAlign.center,
                style: AppTextStyle.text2.copyWith(color: AppColors.lightSub1),
              ),
              SizedBox(height: AppSpacing.s24),
              PrimaryActionButton(
                label: '다시 로그인',
                expand: true,
                onPressed: _login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
