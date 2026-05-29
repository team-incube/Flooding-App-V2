import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/color/app_colors.dart';

/// authorize 콜백 결과(code/state 또는 error).
class OAuthCallback {
  const OAuthCallback({this.code, this.state, this.error});

  final String? code;
  final String? state;
  final String? error;

  bool get isSuccess => code != null && error == null;
}

/// DataGSM authorize 페이지를 웹뷰로 띄우고, 리다이렉트 스킴을 가로채
/// [OAuthCallback] 으로 결과를 반환한다.
class OAuthWebViewPage extends StatefulWidget {
  const OAuthWebViewPage({
    super.key,
    required this.authorizeUri,
    required this.redirectUri,
  });

  final Uri authorizeUri;
  final String redirectUri;

  @override
  State<OAuthWebViewPage> createState() => _OAuthWebViewPageState();
}

class _OAuthWebViewPageState extends State<OAuthWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.lightBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigation,
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(widget.authorizeUri);
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    if (!request.url.startsWith(widget.redirectUri)) {
      return NavigationDecision.navigate;
    }
    // 콜백 스킴은 OS로 넘기지 않고 여기서 가로채 파라미터를 추출한다.
    if (!_handled) {
      _handled = true;
      final uri = Uri.parse(request.url);
      _finish(
        OAuthCallback(
          code: uri.queryParameters['code'],
          state: uri.queryParameters['state'],
          error: uri.queryParameters['error'],
        ),
      );
    }
    return NavigationDecision.prevent;
  }

  void _finish(OAuthCallback result) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.lightMainText),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.lightP1),
            ),
        ],
      ),
    );
  }
}
