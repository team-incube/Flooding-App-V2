import 'package:flooding_v2/feature/dormitory/presentation/pages/song_detail_view.dart';
import 'package:flooding_v2/feature/massage/widget/massage_request_view.dart';
import 'package:flooding_v2/feature/member/domain/repositories/member_repository.dart';
import 'package:flooding_v2/feature/member/domain/usecases/get_massage_members_usecase.dart';
import 'package:flooding_v2/feature/member/domain/usecases/get_study_members_usecase.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_bloc.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_event.dart';
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

GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    initialLocation: RoutePath.home,
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.status == AuthStatus.authenticated;
      final loggingIn = state.matchedLocation == RoutePath.login;

      if (!loggedIn) return loggingIn ? null : RoutePath.login;
      if (loggingIn) return RoutePath.home;
      return null;
    },
    routes: [
      ShellRoute(
        routes: [
          GoRoute(
            path: RoutePath.home,
            builder: (context, state) {
              return const HomeView(studyCount: 4, massageCount: 4);
            },
          ),
          GoRoute(
            path: RoutePath.dormitory,
            builder: (context, state) {
              return const DormitoryView(studyCount: 4, massageCount: 4);
            },
          ),
          GoRoute(
            path: RoutePath.requestStudy,
            builder: (context, state) => BlocProvider(
              create: (context) => MemberListBloc(
                getMembers: GetStudyMembersUseCase(
                  context.read<MemberRepository>(),
                ),
              )..add(MemberListEvent.load()),
              child: const StudyRequestView(),
            ),
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

          return RepositoryProvider(
            create: (_) => MemberRepository(),
            child: BaseScaffold(
              floatingActionButton: floatingButton,
              body: child,
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