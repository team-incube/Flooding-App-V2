import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../models/chat_message.dart';

/// 채팅 메시지 한 줄.
///
/// 사용자 메시지는 우측 정렬(메인 컬러 버블), AI 메시지는 좌측 정렬
/// (봇 아바타 + 밝은 버블)로 보여준다.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  // 버블이 화면 가로의 최대 비율(긴 문장 줄바꿈 유도).
  static const double _maxWidthFactor = 0.75;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * _maxWidthFactor;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: message.isUser
            ? _Bubble(message: message)
            : Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BotAvatar(),
                  const SizedBox(width: AppSpacing.s8),
                  Flexible(child: _Bubble(message: message)),
                ],
              ),
      ),
    );
  }
}

/// 봇 아바타(밝은 메인 틴트 배경 + 챗봇 아이콘).
class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.s36,
      height: AppSize.s36,
      decoration: const BoxDecoration(
        color: AppColors.lightP2,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppIcon.chatBot(size: AppSize.s24, color: AppColors.lightP1),
    );
  }
}

/// 말풍선 본체.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    const radius = Radius.circular(AppRadius.s16);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.lightP1 : AppColors.lightBgSurface,
        borderRadius: BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomLeft: isUser ? radius : Radius.zero,
          bottomRight: isUser ? Radius.zero : radius,
        ),
        border: isUser ? null : Border.all(color: AppColors.lightSub3),
      ),
      child: Text(
        message.text,
        style: AppTextStyle.text3.copyWith(
          color: isUser ? AppColors.lightBgSurface : AppColors.lightMainText,
          height: 1.4,
        ),
      ),
    );
  }
}
