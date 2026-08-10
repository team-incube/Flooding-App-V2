import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flutter/material.dart';

import '../models/homebase_reservation_model.dart';

class HomebaseReservationContainer extends StatelessWidget {
  const HomebaseReservationContainer({
    super.key,
    required this.reservation,
    required this.onDelete,
  });

  final HomebaseReservationModel reservation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final studentsText = reservation.students
        .map((student) => '${student.schoolNb} ${student.name}')
        .join(', ');
    final periodsText = reservation.periods
        .map((period) => '$period교시')
        .join(', ');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightSub2, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '테이블${reservation.tableNumber}',
                  style: AppTextStyle.text3.copyWith(
                    color: AppColors.lightMainText,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                IconButton(
                  onPressed: onDelete,
                  icon: AppIcon.trash(color: AppColors.negative),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              studentsText,
              style: AppTextStyle.text4.copyWith(color: AppColors.lightSub1),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              '교시: $periodsText',
              style: AppTextStyle.text4.copyWith(color: AppColors.lightSub2),
            ),
          ],
        ),
      ),
    );
  }
}
