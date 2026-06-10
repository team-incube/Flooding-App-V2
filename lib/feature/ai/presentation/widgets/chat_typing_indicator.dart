import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/color/app_colors.dart';

/// AI 응답을 기다리는 동안 보여주는 로딩 인디케이터.
///
/// 점 세 개가 위상 차를 두고 순차적으로 위로 튀어올랐다 내려온다.
class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  static const int _dotCount = 3;
  static const double _dotSize = 8;
  static const double _dotSpacing = 6;
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
    return SizedBox(
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
          color: AppColors.lightSub3,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
