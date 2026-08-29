import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';

/// 하단 메시지 입력 바.
///
/// 텍스트 입력 필드 + 전송 버튼으로 구성되며, 입력값이 비어 있으면
/// 전송 버튼이 비활성 상태가 된다.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = '메시지를 입력하세요',
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        color: AppColors.lightBackground,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _InputField(controller: controller, hint: hintText)),
            const SizedBox(width: AppSpacing.s8),
            _SendButton(controller: controller, onSend: onSend),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSize.s52),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.s8),
        border: Border.all(color: AppColors.lightSub2),
      ),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 4,
        textInputAction: TextInputAction.newline,
        style: AppTextStyle.text3.copyWith(
          color: AppColors.lightMainText,
          height: 1.3,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyle.text3.copyWith(color: AppColors.lightSub2),
        ),
      ),
    );
  }
}

/// 전송 버튼(입력값 유무에 따라 색이 바뀐다).
class _SendButton extends StatelessWidget {
  const _SendButton({required this.controller, required this.onSend});

  final TextEditingController controller;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    // 입력값 변화에 따라 활성/비활성 색을 갱신한다.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final enabled = value.text.trim().isNotEmpty;

        return Material(
          color: enabled ? AppColors.lightP1 : AppColors.lightP3,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? () => onSend(value.text.trim()) : null,
            child: SizedBox(
              width: AppSize.s40,
              height: AppSize.s40,
              child: Center(child: AppIcon.sendArrow(size: AppSize.s24)),
            ),
          ),
        );
      },
    );
  }
}
