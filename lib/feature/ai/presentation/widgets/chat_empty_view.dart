import 'package:flutter/material.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';

/// 채팅 기록이 없을 때 보여주는 빈 상태 화면.
///
/// TODO(figma): 디자인 확정 후 문구·일러스트 교체 예정(별도 수정).
class ChatEmptyView extends StatelessWidget {
  const ChatEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.s84,
            height: AppSize.s84,
            decoration: const BoxDecoration(
              color: AppColors.lightP2,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppIcon.chatBot(size: AppSize.s52, color: AppColors.lightP1),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            '무엇을 도와드릴까요?',
            style: AppTextStyle.title3.copyWith(color: AppColors.lightMainText),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '궁금한 점을 입력하면 AI가 답변해드려요',
            style: AppTextStyle.caption1.copyWith(color: AppColors.lightSub1),
          ),
        ],
      ),
    );
  }
}
