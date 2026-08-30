import 'package:flooding_v2/feature/song/presentation/widgets/wake_music_card.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../massage/presentation/widgets/massage_count_card.dart';
import '../../../study/presentation/widgets/study_count_card.dart';

class DormitoryView extends StatelessWidget {
  const DormitoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const StudyCountCard(),
            SizedBox(height: AppSpacing.s16),
            const MassageCountCard(),
            SizedBox(height: AppSpacing.s16),
            const WakeMusicCard(),
          ],
        ),
      ),
    );
  }
}
