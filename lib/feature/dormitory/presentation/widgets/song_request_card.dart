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

  const SongRequestCard({
    super.key,
    required this.song,
    required this.grade,
    required this.name,
    required this.requestedAt,
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
                Container(
                  height: 70,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.lightSub4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                    },
                    icon: Align(
                      alignment: Alignment.topLeft,
                        child: isLiked ? AppIcon.filledHeart() : AppIcon.heart()),
                    padding: const EdgeInsets.all(6),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 12,
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
                        const SizedBox(height: AppSpacing.s4),
                        Row(
                          children: [
                            Text(
                              '${widget.grade} ${widget.name}',
                              style: AppTextStyle.caption1.copyWith(
                                color: AppColors.lightSub1,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s4),
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
                Material(
                  color: AppColors.lightSub4,
                  borderRadius: BorderRadius.circular(8),

                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      height: 41,
                      width: 41,
                      padding: const EdgeInsets.all(8),
                      child: AppIcon.trash(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
