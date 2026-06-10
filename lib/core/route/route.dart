import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../feature/ai/presentation/pages/ai_chat_page.dart';
import '../../feature/dormitory/presentation/widgets/dormitory_view.dart';
import '../../feature/home/presentation/widgets/home_view.dart';
import '../../feature/study/presentation/widgets/request_study_view.dart';
import '../widgets/scaffold/base_scaffold.dart';
import '../widgets/scaffold/floating_button/floating_actions.dart';
import '../../feature/auth/presentation/auth_controller.dart';
import '../../feature/auth/presentation/pages/login_page.dart';
import 'route_path.dart';

/// 인증 상태에 따라 라우팅을 가드하는 go_router 를 생성한다.
///
/// [auth] 를 `refreshListenable` 로 구독해 상태가 바뀌면 redirect 가
/// 재평가된다 — 로그인 성공 시 홈으로, 세션 만료 시 로그인으로 자동 전환된다.
/// 시작 시 토큰 확인은 runApp 이전에 끝나므로 별도 스플래시 라우트는 두지 않는다.
GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    initialLocation: RoutePath.home,
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.status == AuthStatus.authenticated;
      final loggingIn = state.matchedLocation == RoutePath.login;

      // 미인증 — 로그인 화면으로 모은다.
      if (!loggedIn) return loggingIn ? null : RoutePath.login;
      // 인증된 채로 로그인 화면에 있으면 홈으로 보낸다.
      if (loggingIn) return RoutePath.home;
      return null;
    },
    routes: [
      ShellRoute(
        routes: [
          GoRoute(
            path: RoutePath.home,
            builder: (context, state) {
              //TODO : controller로부터 현재 신청 인원 불러오기
              return const HomeView(studyCount: 4, massageCount: 4);
            },
          ),
          GoRoute(
            path: RoutePath.dormitory,
            builder: (context, state) {
              //TODO : controller에서 현재 신청 인원 불러오기
              return const DormitoryView(studyCount: 4, massageCount: 4);
            },
          ),
          GoRoute(
            path: RoutePath.requestStudy,
            //TODO : 자습 신청 패이지 구현
            builder: (context, state) => const RequestStudyView(),
          ),
          GoRoute(
            path: RoutePath.requestMassage,
            //TODO : 안마의자 신청 페이지 구현
            builder: (context, state) => const Column(children: []),
          ),
        ],
        builder: (context, state, child) {
          final location = state.uri.path;

          /// 현재 경로에 따른 floatingActions 분기
          final floatingButton = switch (location) {
            RoutePath.requestStudy ||
            RoutePath.requestMassage => const FloatingActions.aiChat(),
            _ => const FloatingActions.both(),
          };

          return BaseScaffold(
            floatingActionButton: floatingButton,
            body: child,
          );
        },
      ),
      GoRoute(
        path: RoutePath.aiChat,
        builder: (context, state) => const AiChatPage(),
      ),
      GoRoute(
        path: RoutePath.login,
        builder: (context, state) => LoginPage(controller: auth),
      ),
    ],
  );
}
