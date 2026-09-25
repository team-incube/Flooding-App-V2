/// 홈베이스 신청 가능 시간 정책.
///
/// 홈베이스 신청은 매일 **14:20 부터** 가능하다.
///
/// 학교가 한국에 있으므로 기기 시간대와 무관하게 항상 한국 표준시(KST, UTC+9)로
/// 환산해 판정한다. 시각 비교는 분 단위로만 수행하므로 초는 무시한다.
class HomebaseRequestPolicy {
  const HomebaseRequestPolicy();

  static const int openHour = 14;
  static const int openMinute = 20;

  static const int _openInMinutes = openHour * 60 + openMinute;

  /// [now] 가 신청 가능 시간(14:20 이후)인지 여부.
  bool isOpenAt(DateTime now) {
    final kst = now.toUtc().add(const Duration(hours: 9));
    return kst.hour * 60 + kst.minute >= _openInMinutes;
  }
}
