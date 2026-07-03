import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/core/network/api_exception.dart';
import 'package:flooding_v2/feature/home/data/models/period_data.dart';
import 'package:flooding_v2/feature/home/data/models/timetable_data.dart';
import 'package:flooding_v2/feature/home/domain/repositories/neis_repository.dart';
import 'package:flooding_v2/feature/home/domain/usecases/get_next_period_usecase.dart';

/// 테스트용 [NeisRepository] — fetchTimetable 결과/예외를 주입한다.
class _FakeNeisRepository implements NeisRepository {
  _FakeNeisRepository({this.periods = const [], this.error});

  final List<PeriodData> periods;
  final Object? error;

  @override
  Future<TimetableData> fetchTimetable({
    required int grade,
    required int classNumber,
    required DateTime date,
  }) async {
    if (error != null) throw error!;
    return TimetableData(
      date: date,
      grade: grade,
      classNumber: classNumber,
      periods: periods,
    );
  }
}

void main() {
  // KST 09:00(1교시 진행 중)에 해당하는 시각.
  final duringClass = DateTime.utc(2026, 6, 16, 0).subtract(const Duration(hours: 9));
  // KST 18:00(하교 이후)에 해당하는 시각.
  final afterSchool = DateTime.utc(2026, 6, 16, 18).subtract(const Duration(hours: 9));

  group('GetNextPeriodUseCase', () {
    test('일과 중이고 시간표에 해당 교시가 있으면 found', () async {
      final usecase = GetNextPeriodUseCase(
        _FakeNeisRepository(
          periods: [
            PeriodData(period: 1, subject: 'SQL활용', teacher: '이주원', classroom: 401),
          ],
        ),
        clock: () => duringClass,
      );

      final result = await usecase(grade: 2, classNumber: 1);

      expect(result.status, NextPeriodStatus.found);
      expect(result.period?.subject, 'SQL활용');
    });

    test('일과 중이지만 그 교시에 수업이 없으면 noClass', () async {
      final usecase = GetNextPeriodUseCase(
        _FakeNeisRepository(periods: const []),
        clock: () => duringClass,
      );

      final result = await usecase(grade: 2, classNumber: 1);

      expect(result.status, NextPeriodStatus.noClass);
      expect(result.period, isNull);
    });

    test('하교 이후면 조회 없이 dayOver', () async {
      final usecase = GetNextPeriodUseCase(
        _FakeNeisRepository(
          periods: [
            PeriodData(period: 1, subject: 'SQL활용', teacher: '이주원', classroom: 401),
          ],
        ),
        clock: () => afterSchool,
      );

      final result = await usecase(grade: 2, classNumber: 1);

      expect(result.status, NextPeriodStatus.dayOver);
      expect(result.period, isNull);
    });

    test('ApiException 은 메시지를 가진 Exception 으로 변환한다', () async {
      final usecase = GetNextPeriodUseCase(
        _FakeNeisRepository(error: const ApiException(isNetwork: true)),
        clock: () => duringClass,
      );

      expect(
        () => usecase(grade: 2, classNumber: 1),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('네트워크 연결을 확인해 주세요.'),
          ),
        ),
      );
    });
  });
}
