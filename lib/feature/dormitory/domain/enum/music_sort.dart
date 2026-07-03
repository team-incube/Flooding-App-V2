/// 기상음악 목록 정렬 기준 — `GET /dormitory/music` 의 `sort` 쿼리 값.
enum MusicSort {
  /// 신청 시간순(기본).
  time('TIME'),

  /// 좋아요순.
  like('LIKE');

  const MusicSort(this.query);

  /// 서버로 보내는 쿼리 문자열.
  final String query;
}
