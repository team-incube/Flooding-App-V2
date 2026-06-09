import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../models/chat_message.dart';

/// 채팅 메시지 한 줄.
///
/// 사용자 메시지는 우측 정렬(메인 컬러 버블), AI 메시지는 좌측 정렬
/// (밝은 회색 버블)로 보여준다.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  // 버블이 화면 가로의 최대 비율(긴 문장 줄바꿈 유도).
  static const double _maxWidthFactor = 0.75;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * _maxWidthFactor;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          decoration: BoxDecoration(
            color: isUser ? AppColors.lightP1 : AppColors.lightSub3,
            borderRadius: isUser
                ? const BorderRadius.only(
                    topLeft: AppRadius.r16,
                    topRight: AppRadius.r16,
                    bottomLeft: AppRadius.r16,
                    bottomRight: AppRadius.r4,
                  )
                : const BorderRadius.only(
                    topLeft: AppRadius.r16,
                    topRight: AppRadius.r16,
                    bottomLeft: AppRadius.r4,
                    bottomRight: AppRadius.r16,
                  ),
          ),
          child: Text(
            message.text,
            style: AppTextStyle.text4.copyWith(
              color: isUser ? AppColors.lightBackground : AppColors.lightSub1,
            ),
          ),
        ),
      ),
    );
  }
}
