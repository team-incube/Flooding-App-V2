/// 안마의자 신청 버튼의 상태.
enum MassageActionStatus {
  /// 신청 가능 시간이 아님 — 버튼 비활성.
  closed,

  /// 신청 가능 — 누르면 신청.
  ready,

  /// 신청 완료 — 누르면 취소.
  applied,

  /// 신청/취소 요청 처리 중.
  submitting,
}
