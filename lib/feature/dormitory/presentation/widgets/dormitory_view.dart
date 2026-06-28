import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../massage/presentation/widgets/massage_count_card.dart';
import '../../../study/presentation/widgets/study_count_card.dart';

class DormitoryView extends StatelessWidget {
  const DormitoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          StudyCountCard(),
          SizedBox(height: AppSpacing.s16),
          MassageCountCard(),
        ],
      ),
    );
  }
}
