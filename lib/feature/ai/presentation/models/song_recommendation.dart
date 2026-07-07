import 'package:flutter/widgets.dart';

/// 추천 곡 한 개(노래 추천 팝업 표시용).
class SongRecommendation {
  const SongRecommendation({
    required this.title,
    this.thumbnail,
    this.duration,
  });

  final String title;

  /// 곡 썸네일. null이면 회색 플레이스홀더를 보여준다.
  final ImageProvider? thumbnail;

  /// 영상 길이 표기(예: '3:08'). null이면 표시하지 않는다.
  final String? duration;
}
