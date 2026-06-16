import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/feature/study/data/models/study_applicant.dart';
import 'package:flooding_v2/feature/study/domain/study_repository.dart';
import 'package:flooding_v2/feature/study/presentation/cubit/study_action_cubit.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository({this.requestError});

  final Object? requestError;
  int requestCount = 0;
  int cancelCount = 0;

  @override
  Future<List<StudyApplicant>> fetchApplicants() async => const [];

  @override
  Future<void> requestStudy() async {
    requestCount++;
    if (requestError != null) throw requestError!;
  }

  @override
  Future<void> cancelStudy() async {
    cancelCount++;
  }
}

void main() {
  DateTime open() => DateTime(2026, 6, 16, 20, 30);
  DateTime closed() => DateTime(2026, 6, 16, 19, 0);

  group('StudyActionCubit', () {
    test('신청 시간이 아니면 closed 이고 submit 은 무시된다', () async {
      final repo = _FakeStudyRepository();
      final cubit = StudyActionCubit(repository: repo, clock: closed);

      expect(cubit.state, StudyActionStatus.closed);
      final result = await cubit.submit();
      expect(result, isNull);
      expect(repo.requestCount, 0);
    });

    test('신청 시간이면 ready → submit 성공 시 applied', () async {
      final repo = _FakeStudyRepository();
      final cubit = StudyActionCubit(repository: repo, clock: open);

      expect(cubit.state, StudyActionStatus.ready);
      final result = await cubit.submit();

      expect(result?.success, isTrue);
      expect(cubit.state, StudyActionStatus.applied);
      expect(repo.requestCount, 1);
    });

    test('applied 상태에서 submit 하면 취소되어 ready 로 돌아간다', () async {
      final repo = _FakeStudyRepository();
      final cubit = StudyActionCubit(repository: repo, clock: open);
      await cubit.submit(); // applied

      final result = await cubit.submit(); // cancel

      expect(result?.success, isTrue);
      expect(cubit.state, StudyActionStatus.ready);
      expect(repo.cancelCount, 1);
    });

    test('신청 실패 시 상태를 되돌리고 실패 메시지를 반환한다', () async {
      final repo = _FakeStudyRepository(
        requestError: const StudyException(
          StudyFailureReason.conflict,
          '이미 신청했어요.',
        ),
      );
      final cubit = StudyActionCubit(repository: repo, clock: open);

      final result = await cubit.submit();

      expect(result?.success, isFalse);
      expect(result?.message, '이미 신청했어요.');
      expect(cubit.state, StudyActionStatus.ready);
    });
  });

  group('StudyActionStatusX', () {
    test('라벨/활성 매핑', () {
      expect(StudyActionStatus.closed.actionLabel, '신청 불가');
      expect(StudyActionStatus.closed.actionEnabled, isFalse);
      expect(StudyActionStatus.ready.actionLabel, '신청하기');
      expect(StudyActionStatus.ready.actionEnabled, isTrue);
      expect(StudyActionStatus.applied.actionLabel, '신청취소');
      expect(StudyActionStatus.applied.actionEnabled, isTrue);
      expect(StudyActionStatus.submitting.actionEnabled, isFalse);
    });
  });
}
