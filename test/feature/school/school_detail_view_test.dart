import 'package:flooding_v2/core/widgets/primary_action_button.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_bloc.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_event.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_state.dart';
import 'package:flooding_v2/feature/school/domain/repositories/school_repository.dart';
import 'package:flooding_v2/feature/school/presentation/bloc/school_bloc.dart';
import 'package:flooding_v2/feature/school/presentation/widgets/school_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSchoolRepository implements SchoolRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMeBloc extends Bloc<MeEvent, MeState> implements MeBloc {
  _FakeMeBloc() : super(const MeState.initial());
}

void main() {
  // 정책은 KST(UTC+9) 기준이므로 KST 벽시계 시각을 UTC 로 환산해 넘긴다.
  DateTime at(int hour, int minute) =>
      DateTime.utc(2026, 6, 16, hour, minute).subtract(const Duration(hours: 9));

  Future<void> pumpView(WidgetTester tester, DateTime Function() clock) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(402, 874),
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<SchoolBloc>(
              create: (_) => SchoolBloc(repository: _FakeSchoolRepository()),
            ),
            BlocProvider<MeBloc>(create: (_) => _FakeMeBloc()),
          ],
          child: MaterialApp(
            home: Scaffold(body: SchoolDetailView(clock: clock)),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  bool buttonEnabled(WidgetTester tester) =>
      tester.widget<PrimaryActionButton>(find.byType(PrimaryActionButton)).enabled;

  testWidgets('13:30 전에는 버튼이 비활성화되고 안내 문구가 보인다', (tester) async {
    await pumpView(tester, () => at(13, 0));

    expect(buttonEnabled(tester), isFalse);
    expect(find.text('오후 1시 30분부터 신청할 수 있어요'), findsOneWidget);
    expect(find.text('예약하기'), findsNothing);
  });

  testWidgets('13:30 이 되면 자동으로 버튼이 활성화된다', (tester) async {
    await pumpView(tester, () => at(13, 0));
    expect(buttonEnabled(tester), isFalse);

    await tester.pump(const Duration(minutes: 30));

    expect(buttonEnabled(tester), isTrue);
    expect(find.text('예약하기'), findsOneWidget);
  });

  testWidgets('13:30 이후에 들어오면 처음부터 활성화돼 있다', (tester) async {
    await pumpView(tester, () => at(15, 0));

    expect(buttonEnabled(tester), isTrue);
    expect(find.text('예약하기'), findsOneWidget);
  });
}
