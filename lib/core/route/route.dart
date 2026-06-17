import 'package:flooding_v2/feature/dormitory/presentation/pages/song_detail_view.dart';
import 'package:flooding_v2/feature/massage/widget/massage_request_view.dart';
import 'package:flooding_v2/feature/member/domain/repositories/member_repository.dart';
import 'package:flooding_v2/feature/member/domain/usecases/get_massage_members_usecase.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_bloc.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_event.dart';
import 'package:flooding_v2/feature/study/data/repositories/study_repository_impl.dart';
import 'package:flooding_v2/feature/study/domain/repositories/study_repository.dart';
import 'package:flooding_v2/feature/study/domain/usecases/get_study_applicants_usecase.dart';
import 'package:flooding_v2/feature/study/presentation/bloc/study_bloc.dart';
import 'package:flooding_v2/feature/study/presentation/bloc/study_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../feature/ai/presentation/pages/ai_chat_page.dart';
import '../../feature/dormitory/presentation/widgets/dormitory_view.dart';
import '../../feature/home/presentation/widgets/home_view.dart';
import '../../feature/study/presentation/widgets/study_request_view.dart';
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
              //TODO : 안마의자 신청 인원도 API 로 불러오기 (자습은 StudyBloc 로 로드)
              return const HomeView(massageCount: 4);
            },
          ),
          GoRoute(
            path: RoutePath.dormitory,
            builder: (context, state) {
              //TODO : 안마의자 신청 인원도 API 로 불러오기 (자습은 StudyBloc 로 로드)
              return const DormitoryView(massageCount: 4);
            },
          ),
          GoRoute(
            path: RoutePath.requestStudy,
            builder: (context, state) => const StudyRequestView(),
          ),
          GoRoute(
            path: RoutePath.requestMassage,
            builder: (context, state) => BlocProvider(
              create: (context) => MemberListBloc(
                getMembers: GetMassageMembersUseCase(
                  context.read<MemberRepository>(),
                ),
              )..add(MemberListEvent.load()),
              child: const MassageRequestView(),
            ),
          ),
          GoRoute(
            path: RoutePath.songRequestDetail,
            builder: (context, state) => const SongDetailView(),
          ),
        ],
        builder: (context, state, child) {
          final location = state.uri.path;

          final floatingButton = switch (location) {
            RoutePath.requestStudy ||
            RoutePath.requestMassage => const FloatingActions.aiChat(),
            _ => const FloatingActions.both(),
          };

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(create: (_) => MemberRepository()),
              RepositoryProvider<StudyRepository>(
                create: (_) => StudyRepositoryImpl.create(),
              ),
            ],
            child: BlocProvider(
              create: (ctx) {
                final repository = ctx.read<StudyRepository>();
                // 셸 진입 시 1회 로드 — 홈/기숙사 카운트 카드가 즉시 채워진다.
                return StudyBloc(
                  getApplicants: GetStudyApplicantsUseCase(repository),
                  repository: repository,
                )..add(const StudyEvent.applicantsRequested());
              },
              child: BaseScaffold(
                floatingActionButton: floatingButton,
                body: child,
              ),
            ),
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