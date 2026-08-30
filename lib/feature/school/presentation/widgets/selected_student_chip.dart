import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/feature/auth/data/models/search_user.dart';
import 'package:flutter/material.dart';

/// 선택된 학생을 나타내는 완전 둥근 필(pill) 모양 칩 — 예약 상세 화면(SchoolDetailView)에서만 쓰인다.
class SelectedStudentChip extends StatelessWidget {
  const SelectedStudentChip({
    super.key,
    required this.student,
    required this.onRemove,
  });

  final SearchUser student;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(38),
        border: Border.all(color: AppColors.lightSub2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${student.studentNumber} ${student.name}',
            style: AppTextStyle.text4.copyWith(color: AppColors.lightSub1),
          ),
          SizedBox(width: AppSpacing.s8),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.lightSub2,
            ),
          ),
        ],
      ),
    );
  }
}
