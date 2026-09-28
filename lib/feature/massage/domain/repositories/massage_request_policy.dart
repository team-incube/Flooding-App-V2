/// 안마의자 신청 가능 시간에 대한 상태.
enum MassageWindowStatus {
  /// 신청 시작(20:20) 이전 — 아직 신청할 수 없다.
  beforeOpen,

  /// 신청 가능(20:20 ~ 20:59).
  open,

  /// 마감(21:00 정각) 이후 — 더 이상 신청할 수 없다.
  closed,
}

/// 안마의자 신청 가능 시간 정책.
///
/// 안마의자 신청은 매일 **20:20 부터 21:00 직전까지** 가능하다.
/// 21:00 정각이 되면 마감되어 신청할 수 없다.
///
/// 학교가 한국에 있으므로 기기 시간대와 무관하게 항상 한국 표준시(KST, UTC+9)로
/// 환산해 판정한다. 시각 비교는 분 단위로만 수행하므로 초는 무시한다.
/// (20:59:59 는 [MassageWindowStatus.open], 21:00:00 은 [MassageWindowStatus.closed])
class MassageRequestPolicy {
  const MassageRequestPolicy();

  static const int openHour = 20;
  static const int openMinute = 20;
  static const int closeHour = 21;
  static const int closeMinute = 0;

  static const int _openInMinutes = openHour * 60 + openMinute; // 1220
  static const int _closeInMinutes = closeHour * 60 + closeMinute; // 1260

  /// [now] 를 KST 로 환산한 시:분을 기준으로 현재 신청 가능 상태를 반환한다.
  MassageWindowStatus statusAt(DateTime now) {
    final kst = now.toUtc().add(const Duration(hours: 9));
    final minutesOfDay = kst.hour * 60 + kst.minute;
    if (minutesOfDay < _openInMinutes) return MassageWindowStatus.beforeOpen;
    if (minutesOfDay >= _closeInMinutes) return MassageWindowStatus.closed;
    return MassageWindowStatus.open;
  }

  /// [now] 가 신청 가능 시간대인지 여부.
  bool isOpenAt(DateTime now) => statusAt(now) == MassageWindowStatus.open;
}
