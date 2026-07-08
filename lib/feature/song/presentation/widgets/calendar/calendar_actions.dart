import 'package:flutter/material.dart';

import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';

/// 캘린더 하단 버튼 — 뒤로가기(취소) / 적용.
class CalendarActions extends StatelessWidget {
  const CalendarActions({
    super.key,
    required this.onCancel,
    required this.onApply,
  });

  final VoidCallback onCancel;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onCancel,
            style: _buttonStyle(AppColors.lightP3),
            child: Text(
              '뒤로가기',
              style: AppTextStyle.text4.copyWith(color: AppColors.lightSub4),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: _buttonStyle(AppColors.lightP1),
            child: Text(
              '적용',
              style: AppTextStyle.text4.copyWith(
                color: AppColors.lightBgSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(Color backgroundColor) => ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 14),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );
}
