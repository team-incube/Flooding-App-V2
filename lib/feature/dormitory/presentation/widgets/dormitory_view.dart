import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/request_count_card.dart';

/// 기숙사 섹션 본문.
///
/// 홈과 같은 화면(앱바·드로어 유지)에서 본문만 교체되어 표시된다.
/// TODO: 실제 기숙사 화면 구현으로 교체. 현재는 드로어 전환 연결용 임시
/// 플레이스홀더다.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            RequestCountCard.study(
              current: studyCount,
              onActionPressed: () {
                // Todo: 자습신청 기능 구현
              },
            ),
            const SizedBox(height: AppSpacing.s16),
            RequestCountCard.massage(
              current: massageCount,
              onActionPressed: () {
                // Todo: 안마의자 신청 기능 구현
              },
            ),
          ],
        ),
      ),
    );
  }
}
