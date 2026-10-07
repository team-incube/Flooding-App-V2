import 'package:flooding_v2/core/widgets/primary_action_button.dart';
import 'package:flooding_v2/feature/song/presentation/bloc/music_bloc.dart';
import 'package:flooding_v2/feature/song/presentation/bloc/music_event.dart';
import 'package:flooding_v2/feature/song/presentation/bloc/music_state.dart';
import 'package:flooding_v2/feature/song/presentation/widgets/wake_music_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMusicBloc extends Bloc<MusicEvent, MusicState> implements MusicBloc {
  _FakeMusicBloc() : super(const MusicState());
}

void main() {
  const screen = Size(402, 874);
  const keyboardHeight = 300.0;

  testWidgets('입력창 포커스 시 신청 버튼이 키보드에 가려지지 않는다', (tester) async {
    tester.view.physicalSize = screen * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: screen,
        builder: (context, child) => BlocProvider<MusicBloc>(
          create: (_) => _FakeMusicBloc(),
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // 홈 화면처럼 카드가 화면 하단에 걸치도록 위쪽을 채운다.
                    SizedBox(height: screen.height - 100),
                    const WakeMusicCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // 포커스 프레임 이후 키보드가 올라오는 실제 순서를 흉내 낸다.
    await tester.tap(find.byType(TextField));
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight * 3);
    // 커서 깜빡임 때문에 pumpAndSettle 은 끝나지 않으므로 스크롤 애니메이션만큼 진행한다.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final buttonRect = tester.getRect(find.byType(PrimaryActionButton));
    expect(
      buttonRect.bottom,
      lessThanOrEqualTo(screen.height - keyboardHeight),
    );
  });
}
