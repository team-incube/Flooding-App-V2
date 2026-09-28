import '../../data/models/massage_applicant.dart';

/// 안마의자 신청 도메인 계약.
///
/// 구현체는 신청 가능 시간 정책을 적용하고, 백엔드 오류를
/// `ApiException` 으로 표면화한다.
abstract interface class MassageRepository {
  /// 안마의자 신청자 목록을 조회한다.
  Future<List<MassageApplicant>> fetchApplicants();

  /// 안마의자를 신청한다.
  ///
  /// 신청 가능 시간이 아니면 `ApiException` 을 던진다.
  Future<void> requestMassage();

  /// 안마의자 신청을 취소한다.
  Future<void> cancelMassage();
}
