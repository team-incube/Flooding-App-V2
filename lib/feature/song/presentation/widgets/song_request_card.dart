import 'package:flooding_v2/core/constants/app_radius.dart';
import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flutter/material.dart';

class SongRequestCard extends StatefulWidget {
  final String song;
  final String grade;
  final String name;
  final DateTime requestedAt;

  /// 유튜브 영상 썸네일 URL. null/빈 값이면 회색 박스만 보여준다.
  final String? thumbnailUrl;

  final bool isLiked;

  final VoidCallback? onLikePressed;

  /// 취소(휴지통) 버튼 노출 여부 — 본인 신청 곡이거나 관리자일 때 true.
  final bool canDelete;

  /// 취소(휴지통) 버튼을 눌렀을 때 호출된다. [canDelete] 가 false 면 버튼 자체가 없다.
  final VoidCallback? onDeletePressed;

  const SongRequestCard({
    super.key,
    required this.song,
    required this.grade,
    required this.name,
    required this.requestedAt,
    this.thumbnailUrl,
    this.isLiked = false,
    this.onLikePressed,
    this.canDelete = false,
    this.onDeletePressed,
  });

  @override
  State<SongRequestCard> createState() => _SongRequestCardState();
}

class _SongRequestCardState extends State<SongRequestCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.requestedAt.hour;
    final m = widget.requestedAt.minute;
    return Container(
      color: AppColors.lightBackground,
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 120,
            child: Stack(
              children: [
                // 회색 배경 박스(썸네일 로드 전/실패 시 플레이스홀더).
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightSub4,
                      borderRadius: BorderRadius.circular(AppRadius.s8),
                    ),
                  ),
                ),
                // 회색 박스 위에 얹는 유튜브 썸네일(76.55 × 69.96).
                // 잘라내지 않고 지정 크기에 전체가 들어가도록 축소한다.
                if (widget.thumbnailUrl != null &&
                    widget.thumbnailUrl!.isNotEmpty)
                  Center(
                    child: Image.network(
                      widget.thumbnailUrl!,
                      width: 76.55,
                      height: 69.96,
                      fit: BoxFit.fill,
                      // 로드 실패 시 회색 박스만 남긴다.
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                // 좌상단 좋아요 버튼(썸네일 위에 표시).
                Positioned.fill(
                  child: IconButton(
                    onPressed: widget.onLikePressed,
                    icon: Align(
                      alignment: Alignment.topLeft,
                      child: widget.isLiked
                          ? AppIcon.filledHeart()
                          : AppIcon.heart(),
                    ),

                    padding: EdgeInsets.all(AppSpacing.s6),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.s2,
                horizontal: AppSpacing.s12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.song,
                    style: AppTextStyle.text4.copyWith(
                      color: AppColors.lightMainText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.s4),
                  Row(
                    children: [
                      Text(
                        '${widget.grade} ${widget.name}',
                        style: AppTextStyle.caption1.copyWith(
                          color: AppColors.lightSub1,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s4),
                      Text(
                        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
                        style: AppTextStyle.caption1.copyWith(
                          color: AppColors.lightSub1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 본인 신청 곡 또는 관리자일 때만 취소(휴지통) 버튼을 노출한다.
          if (widget.canDelete)
            Material(
              color: AppColors.lightSub4,
              borderRadius: BorderRadius.circular(AppRadius.s8),

              child: InkWell(
                onTap: widget.onDeletePressed,
                child: Container(
                  height: 41,
                  width: 41,
                  padding: EdgeInsets.all(AppSpacing.s8),
                  child: AppIcon.trash(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
