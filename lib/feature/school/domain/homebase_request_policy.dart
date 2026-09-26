/// 홈베이스 신청 가능 시간 정책.
///
/// 홈베이스 신청은 매일 **13:30 부터** 가능하다.
///
/// 학교가 한국에 있으므로 기기 시간대와 무관하게 항상 한국 표준시(KST, UTC+9)로
/// 환산해 판정한다. 시각 비교는 분 단위로만 수행하므로 초는 무시한다.
class HomebaseRequestPolicy {
  const HomebaseRequestPolicy();

  static const int openHour = 13;
  static const int openMinute = 30;

  static const int _openInMinutes = openHour * 60 + openMinute;

  /// [now] 가 신청 가능 시간(13:30 이후)인지 여부.
  bool isOpenAt(DateTime now) => !_isBeforeOpen(_toKst(now));

  /// [now] 부터 오늘 신청 시작(13:30)까지 남은 시간. 이미 열렸으면 null.
  Duration? untilOpen(DateTime now) {
    final kst = _toKst(now);
    if (!_isBeforeOpen(kst)) return null;
    final open = DateTime.utc(
      kst.year,
      kst.month,
      kst.day,
      openHour,
      openMinute,
    );
    return open.difference(kst);
  }

  DateTime _toKst(DateTime now) => now.toUtc().add(const Duration(hours: 9));

  bool _isBeforeOpen(DateTime kst) =>
      kst.hour * 60 + kst.minute < _openInMinutes;
}
