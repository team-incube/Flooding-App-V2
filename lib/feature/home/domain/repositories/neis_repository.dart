import 'package:flooding_v2/feature/home/data/models/timetable_data.dart';

/// NEIS 시간표 도메인 계약.
///
/// 구현체는 응답 래퍼(`CommonApiResponse`)를 풀어 [TimetableData] 만 반환하고,
/// 백엔드 오류를 `ApiException` 으로 표면화한다.
abstract interface class NeisRepository {
  /// [date] 기준 [grade]학년 [classNumber]반 시간표를 조회한다.
  ///
  /// NEIS 학교 식별 코드(officeCode/schoolCode)는 GSM 고정값이라 구현체가
  /// 자체적으로 채운다.
  Future<TimetableData> fetchTimetable({
    required int grade,
    required int classNumber,
    required DateTime date,
  });
}
