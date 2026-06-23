import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';

/// AI 응답을 기다리는 동안 보여주는 로딩 인디케이터.
///
/// AI 메시지 말풍선([ChatMessageBubble])과 같은 모양(Sub-3 배경, 좌하단만
/// 각진 라운드)의 작은 버블 안에서, 점 세 개가 위상 차를 두고 순차적으로
/// 위로 튀어올랐다 내려온다.
class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  static const int _dotCount = 3;
  static const double _dotSize = 8;
  static const double _dotSpacing = 4;
  static const double _bounceHeight = 6;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 버블 크기(약 52x43)를 맞추기 위한 패딩 — 점/간격 합과 함께 디자인 치수를 만든다.
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s14,
      ),
      decoration: const BoxDecoration(
        color: AppColors.lightSub3,
        // AI 말풍선과 동일하게 좌하단만 각지게 둔다.
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.r16,
          topRight: AppRadius.r16,
          bottomLeft: AppRadius.r4,
          bottomRight: AppRadius.r16,
        ),
      ),
      child: SizedBox(
        height: _dotSize + _bounceHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(_dotCount, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index == _dotCount - 1 ? 0 : _dotSpacing,
              ),
              child: _BouncingDot(
                controller: _controller,
                // 점마다 위상을 어긋나게 해 물결치듯 순차적으로 튀어오르게 한다.
                phase: index / _dotCount,
                size: _dotSize,
                bounceHeight: _bounceHeight,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BouncingDot extends StatelessWidget {
  const _BouncingDot({
    required this.controller,
    required this.phase,
    required this.size,
    required this.bounceHeight,
  });

  final Animation<double> controller;
  final double phase;
  final double size;
  final double bounceHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value - phase) % 1.0;
        // 앞쪽 절반 구간에서만 sin 곡선으로 위로 올라갔다 내려오고, 나머지는 정지.
        final bounce = t < 0.5 ? math.sin(t * 2 * math.pi) : 0.0;
        return Transform.translate(
          offset: Offset(0, -bounceHeight * bounce),
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          // Sub-3 버블 위에서 보이도록 한 단계 진한 회색으로 둔다.
          color: AppColors.lightSub2,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
