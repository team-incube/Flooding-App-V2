import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/request_count_card.dart';
import '../../../study/presentation/widgets/study_count_card.dart';

class DormitoryView extends StatelessWidget {
  const DormitoryView({
    super.key,
    required this.studyCount,
    required this.massageCount,
  });

  final int studyCount;
  final int massageCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          StudyCountCard(current: studyCount),
          const SizedBox(height: AppSpacing.s16),
          RequestCountCard.massage(
            current: massageCount,
            onActionPressed: () {
              // Todo: 안마의자 신청 기능 구현
            },
          ),
        ],
      ),
    );
  }
}
