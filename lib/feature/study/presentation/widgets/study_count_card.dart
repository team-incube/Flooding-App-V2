import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/request_count_card.dart';
import '../cubit/study_action_cubit.dart';

/// 자습 신청 현황 카드.
///
/// [StudyActionCubit] 으로 신청 버튼의 라벨/활성 상태를 구동하고,
/// 신청/취소 결과를 SnackBar 로 안내한다.
class StudyCountCard extends StatelessWidget {
  const StudyCountCard({super.key, required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyActionCubit, StudyActionStatus>(
      builder: (context, status) {
        return RequestCountCard.study(
          current: current,
          actionLabel: status.actionLabel,
          actionEnabled: status.actionEnabled,
          onActionPressed: () async {
            // async 갭 이후 context 사용을 피하기 위해 messenger 를 먼저 캡처한다.
            final messenger = ScaffoldMessenger.of(context);
            final result = await context.read<StudyActionCubit>().submit();
            if (result == null) return;
            messenger.showSnackBar(
              SnackBar(content: Text(result.message)),
            );
          },
        );
      },
    );
  }
}
