import 'package:flooding_v2/core/network/api_exception.dart';
import 'package:flooding_v2/core/utils/logger.dart';
import 'package:flooding_v2/feature/home/data/models/period_data.dart';
import 'package:flooding_v2/feature/home/domain/repositories/class_period_policy.dart';
import 'package:flooding_v2/feature/home/domain/repositories/neis_repository.dart';

/// 오늘 시간표에서 현재 진행 중이거나 다음으로 시작하는 교시를 반환한다.
///
/// 하루 일과가 끝났거나, 해당 교시가 오늘 시간표에 없으면(공강 등) `null`.
class GetNextPeriodUseCase {
  const GetNextPeriodUseCase(
    this._repository, {
    ClassPeriodPolicy policy = const ClassPeriodPolicy(),
    DateTime Function() clock = DateTime.now,
  }) : _policy = policy,
       _clock = clock;

  final NeisRepository _repository;
  final ClassPeriodPolicy _policy;
  final DateTime Function() _clock;

  Future<PeriodData?> call({
    required int grade,
    required int classNumber,
  }) async {
    final now = _clock();
    final periodNumber = _policy.periodNumberAt(now);
    if (periodNumber == null) return null;
    try {
      final timetable = await _repository.fetchTimetable(
        grade: grade,
        classNumber: classNumber,
        date: now,
      );
      for (final period in timetable.periods) {
        if (period.period == periodNumber) return period;
      }
      return null;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e, s) {
      Logger.e('시간표 조회 실패', tag: 'NEIS', error: e, stackTrace: s);
      throw Exception('시간표를 불러오지 못했어요.');
    }
  }
}
