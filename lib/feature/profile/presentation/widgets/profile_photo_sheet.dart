import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/sheet/sheet.dart';

/// 프로필 사진을 등록하는 팝업.
///
/// 점선 영역을 누르면 [onPickTap]이 호출되고, 선택된 이미지가 있으면
/// [preview]로 미리보기를 보여준다. '등록'을 누르면 true를 반환한다.
class ProfilePhotoSheet extends StatelessWidget {
  const ProfilePhotoSheet({super.key, this.onPickTap, this.preview});

  /// 점선 업로더를 눌렀을 때 동작(이미지 선택 트리거).
  final VoidCallback? onPickTap;

  /// 선택된 이미지 미리보기. null이면 비어 있는 안내 상태를 표시한다.
  final ImageProvider? preview;

  /// 사진 등록 팝업을 띄운다. '등록' 시 true, 그 외 닫힘은 null을 반환한다.
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onPickTap,
    ImageProvider? preview,
  }) {
    return showAppFormDialog<bool>(
      context,
      builder: (_) => ProfilePhotoSheet(onPickTap: onPickTap, preview: preview),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSheet(
      header: const AppSheetTitle(title: '프로필 사진 등록'),
      confirmLabel: '등록',
      onConfirm: () => Navigator.of(context).pop(true),
      body: _Uploader(onTap: onPickTap, preview: preview),
    );
  }
}

/// 점선 테두리 업로더 영역.
class _Uploader extends StatelessWidget {
  const _Uploader({this.onTap, this.preview});

  final VoidCallback? onTap;
  final ImageProvider? preview;

  // 디자인 고정 수치.
  static const double _height = 306;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: CustomPaint(
          painter: const _DashedBorderPainter(
            color: AppColors.lightP1,
            radius: AppRadius.s8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.s8),
            child: preview != null
                ? Image(image: preview!, fit: BoxFit.cover)
                : const _EmptyState(),
          ),
        ),
      ),
    );
  }
}

/// 사진 미선택 시 안내 문구(카메라 아이콘 + 설명).
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.lightBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon.camera(color: AppColors.lightSub2),
          const SizedBox(height: AppSpacing.s6),
          Text(
            '프로필 사진을 등록해보세요',
            style: AppTextStyle.text3.copyWith(color: AppColors.lightSub2),
          ),
        ],
      ),
    );
  }
}

/// 둥근 사각형 점선 테두리를 그리는 페인터.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  // 디자인 고정 수치(대시 길이·간격·두께).
  static const double _dashWidth = 4;
  static const double _dashGap = 4;
  static const double _strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final source = Path()..addRRect(rrect);

    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        dashed.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + _dashGap;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color || radius != oldDelegate.radius;
  }
}
