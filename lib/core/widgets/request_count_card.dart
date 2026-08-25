import 'dart:async';
import 'package:flooding_v2/core/route/route_path.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    this.onSeeAllPressed,
    required this.onActionPressed,
    this.actionLabel = '신청 불가',
    this.actionEnabled = false,
  }) : title = '자습신청',
       icon = AppIcon.book,
       total = 50,
       information = '자습 신청 시간은 20:00 ~ 21:00에 신청이 가능해요',
       path = RoutePath.requestStudy;

  /// 따로 action이 정의되어 있지 많으면 직접 이동

  const RequestCountCard.massage({
    super.key,
    required this.current,
    this.onSeeAllPressed,
    required this.onActionPressed,
    this.actionLabel = '신청 불가',
    this.actionEnabled = false,
  }) : title = '안마의자 신청',
       icon = AppIcon.chair,
       total = 5,
       information = '안마 의자 신청 시간은 20:20 ~ 21:00에 신청이 가능해요',
       path = RoutePath.requestMassage;

  /// 따로 action이 정의되어 있지 많으면 직접 이동

  final AppIconBuilder icon;
  final String title;
  final int current;
  final int total;
  final String information;
  final VoidCallback? onSeeAllPressed;
  final VoidCallback onActionPressed;
  final String actionLabel;
  final bool actionEnabled;
  final String path;

  @override
  State<RequestCountCard> createState() => _RequestCountCardState();
}

class _RequestCountCardState extends State<RequestCountCard> {
  final _iconKey = GlobalKey();
  // 말풍선 z-order 기준이 되는 카드 전체 Stack 키.
  final _stackKey = GlobalKey();
  Timer? _timer;
  bool _isShowingInformation = false;

  static double get _iconSize => AppSize.s18;
  // 말풍선과 아이콘 사이 최소 간격.
  static const double _gap = 6.0;
  // 화면 가장자리에서 최소한 이만큼은 띄운다(좌우 대칭 — 중앙 정렬 기준).
  static const double _screenMargin = 20.0;

  void _showComment() {
    if (_isShowingInformation) {
      _hideComment();
      return;
    }
    setState(() => _isShowingInformation = true);
    // 연속 탭 시 이전 타이머를 취소해 카운트다운을 리셋한다.
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), _hideComment);
  }

  void _hideComment() {
    _timer?.cancel();
    if (mounted) setState(() => _isShowingInformation = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 화면 좌우 여백을 뺀 나머지 폭 안에서 실제 안내문을 측정한다 — 말풍선은
  /// 아이콘에 붙지 않고 이 폭 안에서 가운데 정렬되므로, 위치·뒤집힘 판단 모두
  /// 이 실측 크기를 기준으로 계산해야 실제 렌더 결과와 어긋나지 않는다.
  ({double width, double height}) _measureBubble(BuildContext context) {
    final maxBoxWidth = MediaQuery.sizeOf(context).width - _screenMargin * 2;
    final maxTextWidth = maxBoxWidth - _InformationBubble._horizontalPadding * 2;
    final textPainter = TextPainter(
      text: TextSpan(text: widget.information, style: AppTextStyle.caption2),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: maxTextWidth < 0 ? 0 : maxTextWidth);
    return (
      width: textPainter.width + _InformationBubble._horizontalPadding * 2,
      height:
          textPainter.height +
          _InformationBubble._verticalPadding * 2 +
          _InformationBubble._tailHeight,
    );
  }

  /// 아이콘 위쪽에 말풍선을 띄울 공간이 있는지 — 부족하면 아래로 뒤집는다.
  bool _hasRoomAbove(double requiredHeight) {
    final iconBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (iconBox == null || !iconBox.hasSize) return true;
    final iconGlobalTop = iconBox.localToGlobal(Offset.zero).dy;
    // Scaffold.appBar(flooding 로고바)는 body 보다 위쪽 레이어에 그려져 그
    // 영역을 그대로 가려버린다 — 화면 y=0 이 아니라 앱바 아래부터를 실제
    // 사용 가능한 최상단으로 봐야 한다(안 그러면 앱바에 가려지는데도 "공간
    // 있음"으로 잘못 판단해 뒤집히지 않는다).
    final appBarHeight = Scaffold.maybeOf(context)?.appBarMaxHeight ?? 0;
    return iconGlobalTop - appBarHeight - _screenMargin >=
        requiredHeight + _gap;
  }

  /// 화면 폭 기준 가운데 정렬된 상자의 왼쪽 끝 — 카드 전체 Stack 기준
  /// 상대 좌표로 변환해서 반환한다(Positioned.left 에 그대로 쓴다).
  double _centeredStackLeft(double boxWidth) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final boxGlobalLeft = (screenWidth - boxWidth) / 2;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return 0;
    return stackBox.globalToLocal(Offset(boxGlobalLeft, 0)).dx;
  }

  /// 말풍선 top 위치 — 카드 Stack 기준 상대 좌표.
  double _bubbleTop(bool pointingDown, double bubbleHeight) {
    final iconBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (iconBox == null ||
        !iconBox.hasSize ||
        stackBox == null ||
        !stackBox.hasSize) {
      return 0;
    }
    final iconLocalTop = iconBox.localToGlobal(Offset.zero, ancestor: stackBox).dy;
    return pointingDown
        ? iconLocalTop - bubbleHeight - _gap
        : iconLocalTop + _iconSize + _gap;
  }

  /// 가운데 정렬된 상자의 왼쪽 끝에서 아이콘 중심까지의 거리 — 꼬투리가
  /// (가능한 범위 안에서) 아이콘을 가리키도록 계산한다.
  double _tailDx(double boxWidth) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final boxGlobalLeft = (screenWidth - boxWidth) / 2;
    final iconBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (iconBox == null || !iconBox.hasSize) return boxWidth / 2;
    final iconGlobalCenter =
        iconBox.localToGlobal(Offset.zero).dx + _iconSize / 2;
    return iconGlobalCenter - boxGlobalLeft;
  }

  @override
  Widget build(BuildContext context) {
    final measured = _isShowingInformation ? _measureBubble(context) : null;
    final pointingDown = measured == null ? true : _hasRoomAbove(measured.height);

    return AppCard(
      // 카드 전체를 Stack 으로 감싸서 말풍선을 마지막 자식(최상위 z-order)으로
      // 올린다 — 아이콘만 감싸는 작은 Stack 에서는 Column 의 뒤 자식(텍스트·
      // 진행바·버튼)이 말풍선 위를 덮어버리는 문제가 생겼다.
      child: Stack(
        key: _stackKey,
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CardHeader(icon: widget.icon, title: widget.title),
                  SizedBox(width: AppSpacing.s6),
                  IconButton(
                    key: _iconKey,
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _showComment,
                    icon: AppIcon.warning(size: _iconSize),
                  ),
                  const Spacer(),
                  _SeeAllLink(
                    onPressed:
                        widget.onSeeAllPressed ?? () => context.push(widget.path),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s8),
              Center(
                child: Text(
                  '${widget.current}/${widget.total}',
                  style: AppTextStyle.title1.copyWith(
                    color: AppColors.lightMainText,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s8),
              AppProgressBar(current: widget.current, total: widget.total),
              SizedBox(height: AppSpacing.s8),
              Align(
                alignment: Alignment.centerRight,
                child: PrimaryActionButton(
                  label: widget.actionLabel,
                  enabled: widget.actionEnabled,
                  onPressed: widget.onActionPressed,
                ),
              ),
            ],
          ),
          if (measured != null)
            Positioned(
              left: _centeredStackLeft(measured.width),
              top: _bubbleTop(pointingDown, measured.height),
              child: SizedBox(
                width: measured.width,
                child: _InformationBubble(
                  text: widget.information,
                  pointingDown: pointingDown,
                  tailDx: _tailDx(measured.width),
                ),
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
          SizedBox(width: AppSpacing.s4),
          AppIcon.chevronRight(size: AppSize.s14, color: AppColors.lightSub2),
        ],
      ),
    );
  }
}

class _InformationBubble extends StatelessWidget {
  final String text;
  // true 면 상자가 아이콘 위에 있어 꼬투리가 아래를 가리키고, false 면 상자가
  // 아이콘 아래에 있어 꼬투리가 위를 가리킨다.
  final bool pointingDown;
  // 상자 왼쪽 끝에서 꼬투리까지의 절대 거리(px) — 상자 폭과 무관한 고정값.
  final double tailDx;
  // Painter 와 같은 값을 써야 padding 과 꼬투리 높이가 일치한다.
  static const _tailHeight = 8.0;
  // _RequestCountCardState._hasRoomAbove 도 같은 값으로 높이를 미리 재야
  // 실제 렌더 크기와 어긋나지 않는다.
  static double get _horizontalPadding => AppSpacing.s16;
  static double get _verticalPadding => AppSpacing.s8;

  const _InformationBubble({
    required this.text,
    required this.pointingDown,
    required this.tailDx,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InformationBubblePainter(tailDx: tailDx, pointingDown: pointingDown),
      child: Padding(
        padding: pointingDown
            ? EdgeInsets.fromLTRB(
                _horizontalPadding,
                _verticalPadding,
                _horizontalPadding,
                _verticalPadding + _tailHeight,
              )
            : EdgeInsets.fromLTRB(
                _horizontalPadding,
                _verticalPadding + _tailHeight,
                _horizontalPadding,
                _verticalPadding,
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
  final double tailDx; // 상자 왼쪽 끝에서 꼬투리까지의 절대 거리(px)
  final bool pointingDown;
  final double borderRadius;
  final tailHeight = _InformationBubble._tailHeight;
  // 꼬투리가 둥근 모서리 위에 그려지지 않도록 상자 가장자리에서 띄우는 여유.
  static const _tailMargin = 10.0;

  _InformationBubblePainter({required this.tailDx, required this.pointingDown})
    : borderRadius = AppRadius.s12,
      color = const Color(0xFF2C2C2E);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final boxTop = pointingDown ? 0.0 : tailHeight;
    final boxBottom = pointingDown ? size.height - tailHeight : size.height;

    final path = Path();

    // 말풍선 본체 (둥근 사각형)
    path.addRRect(
      RRect.fromLTRBR(
        0,
        boxTop,
        size.width,
        boxBottom,
        Radius.circular(borderRadius),
      ),
    );

    // 꼬투리 위치 — 상자 폭을 넘거나 둥근 모서리에 걸치지 않도록 clamp.
    final maxPosition = size.width - _tailMargin;
    final position = tailDx.clamp(
      _tailMargin,
      maxPosition < _tailMargin ? _tailMargin : maxPosition,
    );
    const tailWidth = 12;
    final tailBase = pointingDown ? boxBottom : boxTop;
    final tailTip = pointingDown ? boxBottom + tailHeight : boxTop - tailHeight;

    // 꼬투리 삼각형
    path.moveTo(position - tailWidth / 2, tailBase);
    path.conicTo(position, tailTip, position + tailWidth / 2, tailBase, 6);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_InformationBubblePainter old) =>
      old.tailDx != tailDx || old.pointingDown != pointingDown;
}
