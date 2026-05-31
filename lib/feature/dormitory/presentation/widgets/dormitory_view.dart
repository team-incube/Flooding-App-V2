import 'package:flutter/material.dart';

import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/text_style/app_text_style.dart';

/// 기숙사 섹션 본문.
///
/// 홈과 같은 화면(앱바·드로어 유지)에서 본문만 교체되어 표시된다.
/// TODO: 실제 기숙사 화면 구현으로 교체. 현재는 드로어 전환 연결용 임시
/// 플레이스홀더다.
class DormitoryView extends StatelessWidget {
  const DormitoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '기숙사',
        style: AppTextStyle.title2.copyWith(color: AppColors.lightMainText),
      ),
    );
  }
}
