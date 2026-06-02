import 'dart:async';
import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_size.dart';
import '../constants/app_spacing.dart';
import '../theme/color/app_colors.dart';
import '../theme/icon/app_icon.dart';
import '../theme/text_style/app_text_style.dart';
import 'primary_action_button.dart';
import 'app_card.dart';
import 'app_progress_bar.dart';
import 'card_header.dart';

class RequestCountCard extends StatefulWidget {
  const RequestCountCard.study({
    super.key,
    required this.current,
    required this.onSeeAllPressed,
    required this.onActionPressed,
  }) : title = '자습신청',
       icon = AppIcon.book,
       total = 50,
       information = '자습 신청 시간은 20:00 ~ 21:00에 신청이 가능해요',
       // followerAnchor: 버블의 이 지점이 버튼 좌상단에 고정 (x: 좌측 65%, y: 하단)
       bubbleAlignment = const Alignment(-.65, 1),
       bubbleTailOffset = .2; // 꼬투리 위치 — 버블 폭의 20%

  const RequestCountCard.massage({
    super.key,
    required this.current,
    required this.onSeeAllPressed,
    required this.onActionPressed,
  }) : title = '안마의자 신청',
       icon = AppIcon.chair,
       total = 5,
       information = '안마 의자 신청 시간은 20:20 ~ 21:00에 신청이 가능해요',
       // followerAnchor: 버블의 이 지점이 버튼 좌상단에 고정 (x: 좌측 31%, y: 하단)
       bubbleAlignment = const Alignment(-.31, 1),
       bubbleTailOffset = .37; // 꼬투리 위치 — 버블 폭의 37%

  final AppIconBuilder icon;
  final String title;
  final int current;
  final int total;
  final String information;
  final Alignment bubbleAlignment;
  final double bubbleTailOffset;
  final VoidCallback onSeeAllPressed;
  final VoidCallback onActionPressed;

  @override
  State<RequestCountCard> createState() => _RequestCountCardState();
}

class _RequestCountCardState extends State<RequestCountCard> {
  // Target-Follower 를 연결하는 레이어 키.
  final _layerLink = LayerLink();
  final _overlayController = OverlayPortalController();
  Timer? _timer;

  bool isShowingInformation = false;

  void _showComment() {
    if (isShowingInformation) {
      _overlayController.hide();
      _timer?.cancel();
      isShowingInformation = false;
    } else {
      _overlayController.show();
      // 연속 탭 시 이전 타이머를 취소해 카운트다운을 리셋한다.
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 5), () {
        _overlayController.hide();
        isShowingInformation = false;
      });
      isShowingInformation = true;
    }
  }

  @override
  void dispose() {
    // 위젯 소멸 후 hide() 호출을 막기 위해 타이머를 정리한다.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardHeader(icon: widget.icon, title: widget.title),
              const SizedBox(width: AppSpacing.s6),
              OverlayPortal(
                controller: _overlayController,
                // Align 없이 두면 overlay 전체를 채우려 해 위치가 어긋난다.
                overlayChildBuilder: (_) => Align(
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    targetAnchor: Alignment.topLeft,
                    followerAnchor: widget.bubbleAlignment,
                    child: _InformationBubble(
                      text: widget.information,
                      tailOffset: widget.bubbleTailOffset,
                    ),
                  ),
                ),
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _showComment,
                    icon: AppIcon.warning(size: AppSize.s18),
                  ),
                ),
              ),
              const Spacer(),
              _SeeAllLink(onPressed: widget.onSeeAllPressed),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Center(
            child: Text(
              '${widget.current}/${widget.total}',
              style: AppTextStyle.title1.copyWith(
                color: AppColors.lightMainText,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppProgressBar(current: widget.current, total: widget.total),
          const SizedBox(height: AppSpacing.s8),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryActionButton(
              label: '신청 불가',
              enabled: false,
              onPressed: widget.onActionPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '전체보기',
            style: AppTextStyle.caption1.copyWith(
              color: AppColors.lightHintText,
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          AppIcon.chevronRight(size: AppSize.s14, color: AppColors.lightSub2),
        ],
      ),
    );
  }
}

class _InformationBubble extends StatelessWidget {
  final String text;
  final double tailOffset; // 0.0 ~ 1.0, 꼬투리 가로 위치
  // Painter 와 같은 값을 써야 bottom padding 과 꼬투리 높이가 일치한다.
  static const _tailHeight = 8;

  const _InformationBubble({required this.text, required this.tailOffset});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InformationBubblePainter(tailOffset),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s12,
          AppSpacing.s6,
          AppSpacing.s12,
          AppSpacing.s6 + _tailHeight,
        ),
        child: Text(
          text,
          style: AppTextStyle.caption2.copyWith(color: AppColors.lightSub4),
        ),
      ),
    );
  }
}

class _InformationBubblePainter extends CustomPainter {
  final Color color;
  final double tailOffset; // 0.0(좌) ~ 1.0(우)
  final double borderRadius;
  final tailHeight = _InformationBubble._tailHeight;

  _InformationBubblePainter(this.tailOffset)
    : borderRadius = AppRadius.s12,
      color = const Color(0xFF2C2C2E);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final boxHeight = size.height - tailHeight;

    final path = Path();

    // 말풍선 본체 (둥근 사각형)
    path.addRRect(
      RRect.fromLTRBR(
        0,
        0,
        size.width,
        boxHeight,
        Radius.circular(borderRadius),
      ),
    );

    // 꼬투리 위치 계산
    final position = size.width * tailOffset.clamp(0.05, 0.95);
    const tailWidth = 12;

    // 꼬투리 삼각형
    path.moveTo(position - tailWidth / 2, boxHeight);
    path.conicTo(
      position,
      boxHeight + tailHeight,
      position + tailWidth / 2,
      boxHeight,
      6,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_InformationBubblePainter old) =>
      old.tailOffset != tailOffset;
}
