import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/request_count_card.dart';
import '../bloc/study_bloc.dart';
import '../bloc/study_event.dart';
import '../bloc/study_state.dart';

/// 자습 신청 현황 카드.
///
/// [StudyBloc] 으로 신청 버튼의 라벨/활성 상태를 구동하고,
/// 신청/취소 결과를 SnackBar 로 안내한다.
class StudyCountCard extends StatelessWidget {
  const StudyCountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudyBloc, StudyState>(
      listenWhen: (prev, curr) =>
          curr.result != null && curr.result != prev.result,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.result!.message)),
        );
      },
      builder: (context, state) {
        final status = state.actionStatus;
        return RequestCountCard.study(
          current: state.applicantCount,
          actionLabel: status.actionLabel,
          actionEnabled: status.actionEnabled,
          onActionPressed: () => context.read<StudyBloc>().add(
            const StudyEvent.actionSubmitted(),
          ),
        );
      },
    );
  }
}
