import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/text_style/app_text_style.dart';

/// 팝업 하단의 보조(뒤로가기) + 주요(적용·등록·확인) 버튼 한 쌍.
///
/// 필터·사진등록 시트와 확인 다이얼로그가 공유한다. 두 버튼은 1:1 너비로
/// 늘어나며, [onConfirm]이 null이면 주요 버튼이 비활성(연한 색) 상태가 된다.
class SheetActionButtons extends StatelessWidget {
  const SheetActionButtons({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    this.backLabel = '뒤로가기',
    this.onBack,
  });

  /// 주요 버튼 라벨. 예) '적용', '등록', '확인'.
  final String confirmLabel;

  /// 주요 버튼 동작. null이면 버튼이 비활성 처리된다.
  final VoidCallback? onConfirm;

  /// 보조 버튼 라벨.
  final String backLabel;

  /// 보조 버튼 동작. null이면 닫기만 하도록 호출부에서 연결한다.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SheetButton(
            label: backLabel,
            background: AppColors.lightP3,
            textColor: AppColors.lightSub4,
            onTap: onBack,
          ),
        ),
        SizedBox(width: AppSpacing.s8),
        Expanded(
          child: _SheetButton(
            label: confirmLabel,
            background: onConfirm == null
                ? AppColors.lightP3
                : AppColors.lightP1,
            textColor: AppColors.lightBgSurface,
            onTap: onConfirm,
          ),
        ),
      ],
    );
  }
}

/// 시트 버튼 한 개(px32·py14·radius6 고정 스펙).
class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.background,
    required this.textColor,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.s6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.s6),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s32,
            vertical: AppSpacing.s14,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyle.text3.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
