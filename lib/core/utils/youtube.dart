import 'package:flutter/widgets.dart';

/// 유튜브 URL 에서 영상 ID 를 추출한다. 형식을 알 수 없으면 null.
///
/// 지원 형식: `youtu.be/<id>`, `youtube.com/watch?v=<id>`,
/// `youtube.com/embed/<id>`, `youtube.com/shorts/<id>`.
String? youtubeVideoId(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;

  final host = uri.host.toLowerCase();
  if (host.contains('youtu.be')) {
    final first = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    return (first != null && first.isNotEmpty) ? first : null;
  }
  if (host.contains('youtube.com')) {
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;
    final segments = uri.pathSegments;
    final i = segments.indexWhere((s) => s == 'embed' || s == 'shorts');
    if (i != -1 && i + 1 < segments.length) {
      final id = segments[i + 1];
      return id.isNotEmpty ? id : null;
    }
  }
  return null;
}

/// 유튜브 URL 의 썸네일 [ImageProvider]. ID 추출에 실패하면 null.
ImageProvider? youtubeThumbnail(String url) {
  final id = youtubeVideoId(url);
  if (id == null) return null;
  return NetworkImage('https://img.youtube.com/vi/$id/hqdefault.jpg');
}
