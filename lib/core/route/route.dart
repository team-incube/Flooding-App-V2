import 'package:flooding_v2/core/enum/role.dart';
import 'package:flooding_v2/core/route/route_path.dart';
import 'package:flooding_v2/core/widgets/scaffold/base_scaffold.dart';
import 'package:flooding_v2/core/widgets/scaffold/floating_button/floating_action_locations.dart';
import 'package:flooding_v2/core/widgets/scaffold/floating_button/floating_actions.dart';
import 'package:flooding_v2/feature/ai/data/repositories/ai_repository_impl.dart';
import 'package:flooding_v2/feature/ai/domain/repositories/ai_repository.dart';
import 'package:flooding_v2/feature/ai/presentation/bloc/chat_bloc.dart';
import 'package:flooding_v2/feature/ai/presentation/pages/ai_chat_page.dart';
import 'package:flooding_v2/feature/auth/presentation/auth_controller.dart';
import 'package:flooding_v2/feature/auth/presentation/pages/login_page.dart';
import 'package:flooding_v2/feature/dormitory/presentation/widgets/dormitory_view.dart';
import 'package:flooding_v2/feature/home/presentation/widgets/home_view.dart';
import 'package:flooding_v2/feature/massage/data/repositories/massage_repository_impl.dart';
import 'package:flooding_v2/feature/massage/domain/repositories/massage_repository.dart';
import 'package:flooding_v2/feature/massage/domain/usecases/get_massage_applicants_usecase.dart';
import 'package:flooding_v2/feature/massage/presentation/bloc/massage_bloc.dart';
import 'package:flooding_v2/feature/massage/presentation/bloc/massage_event.dart';
import 'package:flooding_v2/feature/massage/presentation/bloc/massage_state.dart';
import 'package:flooding_v2/feature/massage/presentation/widgets/massage_request_view.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_bloc.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_event.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_selection_bloc.dart';
import 'package:flooding_v2/feature/song/data/repositories/music_repository_impl.dart';
import 'package:flooding_v2/feature/song/domain/repositories/music_repository.dart';
import 'package:flooding_v2/feature/song/presentation/bloc/music_bloc.dart';
import 'package:flooding_v2/feature/song/presentation/bloc/music_event.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_bloc.dart';
import 'package:flooding_v2/feature/song/presentation/pages/song_detail_view.dart';
import 'package:flooding_v2/feature/home/data/repositories/neis_repository_impl.dart';
import 'package:flooding_v2/feature/home/domain/usecases/get_next_period_usecase.dart';
import 'package:flooding_v2/feature/home/presentation/bloc/timetable_bloc.dart';
import 'package:flooding_v2/feature/study/data/repositories/study_repository_impl.dart';
import 'package:flooding_v2/feature/study/domain/repositories/study_repository.dart';
import 'package:flooding_v2/feature/study/domain/usecases/get_study_applicants_usecase.dart';
import 'package:flooding_v2/feature/study/presentation/bloc/study_bloc.dart';
import 'package:flooding_v2/feature/study/presentation/bloc/study_event.dart';
import 'package:flooding_v2/feature/study/presentation/bloc/study_state.dart';
import 'package:flooding_v2/feature/study/presentation/widgets/study_request_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// 인증 상태에 따라 라우팅을 가드하는 go_router 를 생성한다.
///
/// [auth] 를 `refreshListenable` 로 구독해 상태가 바뀌면 redirect 가
/// 재평가된다 — 로그인 성공 시 홈으로, 세션 만료 시 로그인으로 자동 전환된다.
/// 시작 시 토큰 확인은 runApp 이전에 끝나므로 별도 스플래시 라우트는 두지 않는다.
GoRouter createAppRouter(AuthController auth) {
  // builder 가 재호출돼도 Dio/TokenStorage 가 매번 새로 생성되지 않도록
  // AI 챗봇 repository 는 라우터 생성 시 한 번만 만들어 재사용한다.
  final aiRepository = AiRepositoryImpl.create(
    onSessionExpired: auth.expireSession,
  );

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
            builder: (context, state) => BlocProvider(
              create: (ctx) => TimetableBloc(
                getNextPeriod: GetNextPeriodUseCase(
                  NeisRepositoryImpl.create(
                    onSessionExpired: auth.expireSession,
                  ),
                ),
                meBloc: ctx.read<MeBloc>(),
              ),
              child: const HomeView(),
            ),
          ),
          GoRoute(
            path: RoutePath.dormitory,
            builder: (context, state) => const DormitoryView(),
          ),
          GoRoute(
            path: RoutePath.requestStudy,
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) {
                    // 셸 StudyBloc 이 이미 받아둔 신청자 목록으로 시드한다 —
                    // 재진입 시 인디케이터 없이 곧장 표시하고 백그라운드로만 갱신
                    // 한다(아직 미로딩이면 null 로 두어 첫 조회에서만 인디케이터).
                    final study = context.read<StudyBloc>().state;
                    // loaded 뿐 아니라 백그라운드 갱신(refreshing) 중에도 이미
                    // 받아둔 목록이 있으므로 시드해 인디케이터를 띄우지 않는다.
                    final seeded =
                        study.listStatus == StudyListStatus.loaded ||
                        study.listStatus == StudyListStatus.refreshing;
                    return MemberListBloc(
                      getMembers: GetStudyApplicantsUseCase(
                        context.read<StudyRepository>(),
                      ),
                      initialMembers: seeded ? study.applicants : null,
                    )..add(MemberListEvent.load());
                  },
                ),
                BlocProvider(create: (context) => MemberSelectionBloc()),
              ],
              child: const StudyRequestView(),
            ),
          ),
          GoRoute(
            path: RoutePath.requestMassage,
            builder: (context, state) => BlocProvider(
              create: (context) {
                // 셸 MassageBloc 이 이미 받아둔 신청자 목록으로 시드한다 —
                // 재진입 시 인디케이터 없이 곧장 표시하고 백그라운드로만 갱신
                // 한다(아직 미로딩이면 null 로 두어 첫 조회에서만 인디케이터).
                final massage = context.read<MassageBloc>().state;
                final seeded = massage.listStatus == MassageListStatus.loaded;
                return MemberListBloc(
                  getMembers: GetMassageApplicantsUseCase(
                    context.read<MassageRepository>(),
                  ),
                  initialMembers: seeded ? massage.applicants : null,
                )..add(MemberListEvent.load());
              },
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
          final isDormManager = context.isManager;

          final floatingButton = switch (location) {
            RoutePath.requestStudy ||
            RoutePath.requestMassage => const FloatingActions.aiChat(),
            _ => const FloatingActions.both(),
          };
          final floatingButtonLocation = switch (location) {
            RoutePath.requestStudy || RoutePath.requestMassage
                when isDormManager =>
              FloatingActionLocations.aiFloatingLocation,
            _ => null,
          };

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider<StudyRepository>(
                create: (_) => StudyRepositoryImpl.create(
                  onSessionExpired: auth.expireSession,
                ),
              ),
              RepositoryProvider<MassageRepository>(
                create: (_) => MassageRepositoryImpl.create(
                  onSessionExpired: auth.expireSession,
                ),
              ),
              RepositoryProvider<MusicRepository>(
                create: (_) => MusicRepositoryImpl.create(
                  onSessionExpired: auth.expireSession,
                ),
              ),
              // 플로팅 노래추천 버튼이 AI 추천 API 를 호출할 수 있도록 공유한다.
              RepositoryProvider<AiRepository>.value(value: aiRepository),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (ctx) {
                    final repository = ctx.read<StudyRepository>();
                    // 셸 진입 시 1회 로드 — 홈/기숙사 카운트 카드가 즉시 채워진다.
                    return StudyBloc(
                      getApplicants: GetStudyApplicantsUseCase(repository),
                      repository: repository,
                    )..add(const StudyEvent.applicantsRequested());
                  },
                ),
                BlocProvider(
                  create: (ctx) {
                    final repository = ctx.read<MassageRepository>();
                    // 셸 진입 시 1회 로드 — 홈/기숙사 카운트 카드가 즉시 채워진다.
                    return MassageBloc(
                      getApplicants: GetMassageApplicantsUseCase(repository),
                      repository: repository,
                    )..add(const MassageEvent.applicantsRequested());
                  },
                ),
                BlocProvider(
                  // 셸 진입 시 1회 로드 — 홈 기상음악 카드 카운트/목록을 채운다.
                  // 이어 SSE 를 구독해 신청·취소·좋아요를 실시간 반영한다.
                  create: (ctx) =>
                      MusicBloc(repository: ctx.read<MusicRepository>())
                        ..add(const MusicEvent.listRequested())
                        ..add(const MusicEvent.subscriptionStarted()),
                ),
              ],
              child: BaseScaffold(
                floatingActionButton: floatingButton,
                floatingActionButtonLocation: floatingButtonLocation,
                onLogout: auth.logout,
                //TODO : 회원 탈퇴 기능
                onWithdraw: auth.logout,
                body: child,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePath.aiChat,
        builder: (context, state) => BlocProvider(
          create: (_) => ChatBloc(repository: aiRepository),
          child: const AiChatPage(),
        ),
      ),
      GoRoute(
        path: RoutePath.login,
        builder: (context, state) => LoginPage(controller: auth),
      ),
    ],
  );
}
