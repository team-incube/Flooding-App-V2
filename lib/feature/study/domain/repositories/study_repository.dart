import '../../data/models/study_applicant.dart';

/// 자습 신청 도메인 계약.
///
/// 구현체는 신청 가능 시간 정책을 적용하고, 백엔드 오류를
/// `ApiException` 으로 표면화한다.
abstract interface class StudyRepository {
  /// 자습 신청자 목록을 조회한다.
  Future<List<StudyApplicant>> fetchApplicants();

  /// 자습을 신청한다.
  ///
  /// 신청 가능 시간이 아니면 `ApiException` 을 던진다.
  Future<void> requestStudy();

  /// 자습 신청을 취소한다.
  Future<void> cancelStudy();
}
