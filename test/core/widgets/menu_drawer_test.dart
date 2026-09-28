import 'package:flooding_v2/core/route/route_path.dart';
import 'package:flooding_v2/core/widgets/scaffold/drawer/menu_drawer.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_event.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_bloc.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeMeBloc extends Bloc<MeEvent, MeState> implements MeBloc {
  _FakeMeBloc() : super(const MeState.initial());
}

void main() {
  // 실제 앱처럼 공통 Scaffold(ShellRoute)를 유지한 채 body 만 바뀌는 구조.
  Widget buildApp() {
    final router = GoRouter(
      initialLocation: RoutePath.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) => BlocProvider<MeBloc>(
            create: (_) => _FakeMeBloc(),
            child: Scaffold(
              body: child,
              endDrawer: const MenuDrawer(name: '테스트', studentNumber: 1101),
            ),
          ),
          routes: [
            GoRoute(
              path: RoutePath.home,
              builder: (context, state) => const Text('홈 화면'),
            ),
            GoRoute(
              path: RoutePath.dormitory,
              builder: (context, state) => const Text('기숙사 화면'),
            ),
          ],
        ),
      ],
    );
    return ScreenUtilInit(
      designSize: const Size(402, 874),
      builder: (context, child) => MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('메뉴 항목을 눌러 이동하면 드로어가 닫힌다', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    tester.state<ScaffoldState>(find.byType(Scaffold)).openEndDrawer();
    await tester.pumpAndSettle();
    expect(find.text('로그아웃'), findsOneWidget);

    await tester.tap(find.text('기숙사'));
    await tester.pumpAndSettle();

    expect(find.text('기숙사 화면'), findsOneWidget);
    expect(find.text('로그아웃'), findsNothing);
  });
}
