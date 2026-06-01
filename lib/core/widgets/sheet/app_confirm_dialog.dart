import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/text_style/app_text_style.dart';

/// 제목 + 안내 문구 + 취소/확인 두 텍스트 버튼으로 구성된 범용 확인 다이얼로그.
///
/// 로그아웃·회원탈퇴처럼 사용자의 확인이 필요한 동작에 쓰는 iOS 알럿 형태다.
/// '확인' 시 true, 취소·바깥 탭 시 null을 반환한다.
abstract final class AppConfirmDialog {
  /// 알럿 최대 너비(iOS 표준 알럿 폭). 넓은 화면에서도 이 이상 커지지 않는다.
  static const double _maxWidth = 270;

  /// 확인 다이얼로그를 띄운다.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = '확인',
    String cancelLabel = '취소',
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.lightMainText.withValues(alpha: 0.4),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.lightBgSurface,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.s16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: _ConfirmContent(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
          ),
        ),
      ),
    );
  }
}

class _ConfirmContent extends StatelessWidget {
  const _ConfirmContent({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s24,
            AppSpacing.s24,
            AppSpacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.title3.copyWith(
                  color: AppColors.lightMainText,
                  fontWeight: AppTextStyle.bold,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.s12),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.text3.copyWith(
                    color: AppColors.lightSub1,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.lightSub3),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _AlertButton(
                  label: cancelLabel,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.lightSub3,
              ),
              Expanded(
                child: _AlertButton(
                  label: confirmLabel,
                  emphasized: true,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 하단 텍스트 버튼 한 개(파란색, 확인 버튼은 강조).
class _AlertButton extends StatelessWidget {
  const _AlertButton({
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        child: Center(
          child: Text(
            label,
            style: AppTextStyle.text2.copyWith(
              color: AppColors.lightP1,
              fontWeight: emphasized
                  ? AppTextStyle.bold
                  : AppTextStyle.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}
