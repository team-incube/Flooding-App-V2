import 'package:flutter/material.dart';

import 'package:flooding_v2/core/config/env.dart';
import 'package:flooding_v2/core/network/network_error_reporter.dart';
import 'package:flooding_v2/core/route/route.dart';
import 'package:flooding_v2/core/theme/config/dark_theme.dart';
import 'package:flooding_v2/core/theme/config/light_theme.dart';
import 'package:flooding_v2/feature/auth/presentation/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  // 저장 토큰 확인을 첫 프레임 전에 끝내, 시작부터 home/login 이 결정되게 한다.
  // (짧은 secure storage 읽기 동안은 OS 런치 스크린이 화면을 덮는다.)
  final authController = AuthController();
  await authController.bootstrap();

  // 사용 중 어느 화면에서든 네트워크 오류가 나면 로그인 화면으로 보낸다.
  // (bootstrap 이후 등록해 시작 시점 처리와 겹치지 않게 한다.)
  NetworkErrorReporter.setListener(authController.reportNetworkError);

  runApp(FloodingApp(authController: authController));
}

class FloodingApp extends StatefulWidget {
  const FloodingApp({super.key, required this.authController});

  final AuthController authController;

  @override
  State<FloodingApp> createState() => _FloodingAppState();
}

class _FloodingAppState extends State<FloodingApp> {
  late final _router = createAppRouter(widget.authController);

  @override
  void dispose() {
    NetworkErrorReporter.setListener(null);
    _router.dispose();
    widget.authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'flooding_v2',
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
