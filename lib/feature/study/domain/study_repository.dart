import '../data/models/study_applicant.dart';

/// 자습 신청/조회/취소 실패 사유.
enum StudyFailureReason {
  /// 신청 가능 시간(20:20 ~ 21:00)이 아님. (클라이언트 정책 또는 서버 400)
  outOfTime,

  /// 자습 금지 상태. (403)
  banned,

  /// 이미 신청했거나, 자습이 비활성이거나, 인원이 초과됨. (409)
  conflict,

  /// 자습 신청 내역이 없음. (404)
  notFound,

  /// 인증 필요/만료. (401)
  unauthorized,

  /// 네트워크 연결 실패·타임아웃.
  network,

  /// 그 외 알 수 없는 오류.
  unknown,
}

/// 자습 관련 도메인 예외.
class StudyException implements Exception {
  const StudyException(this.reason, [this.message]);

  final StudyFailureReason reason;
  final String? message;

  @override
  String toString() => 'StudyException($reason): ${message ?? ''}';
}

/// 자습 신청 도메인 계약.
///
/// 구현체는 신청 가능 시간 정책을 적용하고, 백엔드 오류를
/// [StudyException] 으로 변환해 표면화한다.
abstract interface class StudyRepository {
  /// 자습 신청자 목록을 조회한다.
  Future<List<StudyApplicant>> fetchApplicants();

  /// 자습을 신청한다.
  ///
  /// 신청 가능 시간이 아니면 [StudyException] (`outOfTime`) 을 던진다.
  Future<void> requestStudy();

  /// 자습 신청을 취소한다.
  Future<void> cancelStudy();
}
