import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/request_count_card.dart';
import '../bloc/massage_bloc.dart';
import '../bloc/massage_event.dart';
import '../bloc/massage_state.dart';

/// 안마의자 신청 현황 카드.
///
/// [MassageBloc] 으로 신청 버튼의 라벨/활성 상태를 구동하고,
/// 신청/취소 결과를 SnackBar 로 안내한다.
class MassageCountCard extends StatelessWidget {
  const MassageCountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MassageBloc, MassageState>(
      listenWhen: (prev, curr) =>
          curr.result != null && curr.result != prev.result,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.result!.message)),
        );
      },
      builder: (context, state) {
        final status = state.actionStatus;
        return RequestCountCard.massage(
          current: state.applicantCount,
          actionLabel: status.actionLabel,
          actionEnabled: status.actionEnabled,
          onActionPressed: () => context.read<MassageBloc>().add(
            const MassageEvent.actionSubmitted(),
          ),
        );
      },
    );
  }
}
