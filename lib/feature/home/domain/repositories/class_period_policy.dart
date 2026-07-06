/// GSM 종 시간표(교시별 종료 시각) 기준으로, 주어진 시각에 표시할 교시 번호를
/// 판정한다.
///
/// 진행 중인 교시가 있으면 그 교시를, 쉬는시간/점심시간처럼 교시 사이 시간이면
/// 다음으로 시작하는 교시를 반환한다. 7교시가 끝난 뒤(하교 이후)에는 `null`.
///
/// 학교가 한국에 있으므로 기기 시간대와 무관하게 항상 한국 표준시(KST, UTC+9)로
/// 환산해 판정한다.
class ClassPeriodPolicy {
  const ClassPeriodPolicy();

  /// 교시별 종료 시각(분 단위, 자정 기준). 시작 시각은 판정에 필요 없다 —
  /// 쉬는시간/점심시간엔 이전 교시가 끝난 시점부터 다음 교시가 "다음 교시"이므로,
  /// 각 교시의 끝 시각만 오름차순으로 비교하면 된다.
  static const List<int> _periodEndMinutes = [
    9 * 60 + 30, // 1교시 08:40~09:30
    10 * 60 + 30, // 2교시 09:40~10:30
    11 * 60 + 30, // 3교시 10:40~11:30
    12 * 60 + 30, // 4교시 11:40~12:30 (이후 점심 12:30~13:30)
    14 * 60 + 20, // 5교시 13:30~14:20
    15 * 60 + 20, // 6교시 14:30~15:20
    16 * 60 + 20, // 7교시 15:30~16:20
  ];

  /// [now] 기준 표시할 교시 번호(1~7). 하루 일과가 끝났으면 `null`.
  int? periodNumberAt(DateTime now) {
    final minutesOfDay = _minutesOfDay(now);
    for (var i = 0; i < _periodEndMinutes.length; i++) {
      if (minutesOfDay < _periodEndMinutes[i]) return i + 1;
    }
    return null;
  }

  int _minutesOfDay(DateTime now) {
    final kst = now.toUtc().add(const Duration(hours: 9));
    return kst.hour * 60 + kst.minute;
  }
}
