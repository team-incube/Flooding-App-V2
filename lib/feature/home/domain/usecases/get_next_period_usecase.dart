import 'package:flooding_v2/core/network/api_exception.dart';
import 'package:flooding_v2/core/utils/logger.dart';
import 'package:flooding_v2/feature/home/data/models/period_data.dart';
import 'package:flooding_v2/feature/home/domain/repositories/class_period_policy.dart';
import 'package:flooding_v2/feature/home/domain/repositories/neis_repository.dart';

/// [GetNextPeriodUseCase] 조회 결과 종류.
enum NextPeriodStatus {
  /// 진행 중이거나 다음으로 시작하는 교시를 찾음.
  found,

  /// 하루 일과(1~7교시)가 끝남 — 하교 이후.
  dayOver,

  /// 아직 일과 중이지만 해당 교시에 예정된 수업이 없음(공강·방학 등).
  noClass,
}

/// [GetNextPeriodUseCase] 조회 결과. [status] 로 "왜 교시가 없는지"까지 구분한다.
class NextPeriodResult {
  const NextPeriodResult.found(this.period) : status = NextPeriodStatus.found;

  const NextPeriodResult.dayOver()
    : status = NextPeriodStatus.dayOver,
      period = null;

  const NextPeriodResult.noClass()
    : status = NextPeriodStatus.noClass,
      period = null;

  final NextPeriodStatus status;
  final PeriodData? period;
}

/// 오늘 시간표에서 현재 진행 중이거나 다음으로 시작하는 교시를 반환한다.
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

  Future<NextPeriodResult> call({
    required int grade,
    required int classNumber,
  }) async {
    final now = _clock();
    final periodNumber = _policy.periodNumberAt(now);
    if (periodNumber == null) return const NextPeriodResult.dayOver();
    try {
      final timetable = await _repository.fetchTimetable(
        grade: grade,
        classNumber: classNumber,
        date: now,
      );
      for (final period in timetable.periods) {
        if (period.period == periodNumber) {
          return NextPeriodResult.found(period);
        }
      }
      return const NextPeriodResult.noClass();
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e, s) {
      Logger.e('시간표 조회 실패', tag: 'NEIS', error: e, stackTrace: s);
      throw Exception('시간표를 불러오지 못했어요.');
    }
  }
}
