import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flooding_v2/core/config/env.dart';
import 'package:flooding_v2/core/network/network_error_reporter.dart';
import 'package:flooding_v2/core/route/route.dart';
import 'package:flooding_v2/core/theme/config/light_theme.dart';
import 'package:flooding_v2/feature/auth/data/user_service.dart';
import 'package:flooding_v2/feature/auth/presentation/auth_controller.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_bloc.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  // 저장 토큰 확인을 첫 프레임 전에 끝내, 시작부터 home/login 이 결정되게 한다.
  // (짧은 secure storage 읽기 동안은 OS 런치 스크린이 화면을 덮는다.)
  final authController = AuthController(sessionValidator: UserService());
  await authController.bootstrap();

  // 사용 중 어느 화면에서든 네트워크 오류가 나면 로그인 화면으로 보낸다.
  // (bootstrap 이후 등록해 시작 시점 처리와 겹치지 않게 한다.)
  NetworkErrorReporter.setListener(authController.reportNetworkError);

  runApp(FloodingApp(authController: authController));
}

class FloodingApp extends StatefulWidget {
  const FloodingApp({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  State<FloodingApp> createState() => _FloodingAppState();
}

class _FloodingAppState extends State<FloodingApp> {
  late final _router = createAppRouter(widget.authController);

  // 내 정보 조회·프로필 사진 업로드 등 사용자 API 를 한 인스턴스로 공유한다
  // (드로어 편집에서 매번 새로 만들지 않도록 루트에서 주입).
  late final _userService = UserService(
    onSessionExpired: widget.authController.expireSession,
  );

  // 메뉴 드로어의 이름·학번 표시용 내 정보. 세션 만료 시 로그인으로 보낸다.
  late final _meBloc = MeBloc(userService: _userService);

  @override
  void initState() {
    super.initState();
    // 인증 상태에 맞춰 내 정보를 불러오거나 비운다(로그인 시 로드, 로그아웃 시 초기화).
    widget.authController.addListener(_syncMe);
    _syncMe();
  }

  void _syncMe() {
    if (widget.authController.status == AuthStatus.authenticated) {
      // 시작 시엔 부트스트랩의 세션 검사가 받아온 내 정보를 재사용하고
      // (중복 `/users/me` 제거), 이후 재로그인 등에서는 새로 조회한다.
      final me = widget.authController.takeInitialMe();
      _meBloc.add(me != null ? MeEvent.provided(me) : const MeEvent.requested());
    } else {
      _meBloc.add(const MeEvent.cleared());
    }
  }

  @override
  void dispose() {
    NetworkErrorReporter.setListener(null);
    widget.authController.removeListener(_syncMe);
    _router.dispose();
    _meBloc.close();
    widget.authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserService>.value(
      value: _userService,
      child: BlocProvider.value(
        value: _meBloc,
        child: MaterialApp.router(
          title: 'flooding_v2',
          debugShowCheckedModeBanner: false,
          theme: LightTheme.theme,
          // 앱 UI 가 라이트 전용이라 라이트로 고정한다. system 으로 두면 기기가
          // 다크일 때 ThemeData 만 다크로 바뀌어, 페이지 트랜지션이 배경으로
          // 쓰는 colorScheme.surface 가 검정이 되면서 전환 중 검은 영역이 비친다.
          themeMode: ThemeMode.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
