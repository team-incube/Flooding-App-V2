import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/feature/study/data/models/study_applicant.dart';
import 'package:flooding_v2/core/network/api_exception.dart';
import 'package:flooding_v2/feature/study/domain/enum/study_action_enum.dart';
import 'package:flooding_v2/feature/study/domain/repositories/study_repository.dart';
import 'package:flooding_v2/feature/study/domain/usecases/get_study_applicants_usecase.dart';
import 'package:flooding_v2/feature/study/presentation/bloc/study_bloc.dart';
import 'package:flooding_v2/feature/study/presentation/bloc/study_event.dart';
import 'package:flooding_v2/feature/study/presentation/bloc/study_state.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository({this.requestError, this.applicants = const []});

  final Object? requestError;
  final List<StudyApplicant> applicants;
  Object? fetchError;
  int fetchCount = 0;
  int requestCount = 0;
  int cancelCount = 0;

  @override
  Future<List<StudyApplicant>> fetchApplicants() async {
    fetchCount++;
    if (fetchError != null) throw fetchError!;
    return applicants;
  }

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

StudyBloc _buildBloc(
  _FakeStudyRepository repo, {
  required DateTime Function() clock,
}) => StudyBloc(
  getApplicants: GetStudyApplicantsUseCase(repo),
  repository: repo,
  clock: clock,
);

void main() {
  // 정책은 KST(UTC+9) 기준이므로 시계는 UTC 로 고정해 결정적으로 만든다.
  // 11:30 UTC == 20:30 KST(open), 10:00 UTC == 19:00 KST(closed).
  DateTime open() => DateTime.utc(2026, 6, 16, 11, 30);
  DateTime closed() => DateTime.utc(2026, 6, 16, 10, 0);

  group('StudyBloc 액션', () {
    test('신청 시간이 아니면 closed 이고 submit 은 무시된다', () async {
      final repo = _FakeStudyRepository();
      final bloc = _buildBloc(repo, clock: closed);

      expect(bloc.state.actionStatus, StudyActionStatus.closed);

      bloc.add(const StudyEvent.actionSubmitted());
      await pumpEventQueue();

      expect(repo.requestCount, 0);
      expect(bloc.state.result, isNull);
      await bloc.close();
    });

    test('신청 시간이면 ready → submit 성공 시 applied', () async {
      final repo = _FakeStudyRepository();
      final bloc = _buildBloc(repo, clock: open);

      expect(bloc.state.actionStatus, StudyActionStatus.ready);

      bloc.add(const StudyEvent.actionSubmitted());
      await pumpEventQueue();

      expect(bloc.state.actionStatus, StudyActionStatus.applied);
      expect(bloc.state.result?.success, isTrue);
      expect(repo.requestCount, 1);
      await bloc.close();
    });

    test('applied 상태에서 submit 하면 취소되어 ready 로 돌아간다', () async {
      final repo = _FakeStudyRepository();
      final bloc = _buildBloc(repo, clock: open);

      bloc.add(const StudyEvent.actionSubmitted()); // applied
      await pumpEventQueue();

      bloc.add(const StudyEvent.actionSubmitted()); // cancel
      await pumpEventQueue();

      expect(bloc.state.actionStatus, StudyActionStatus.ready);
      expect(bloc.state.result?.success, isTrue);
      expect(repo.cancelCount, 1);
      await bloc.close();
    });

    test('신청 실패 시 상태를 되돌리고 실패 메시지를 반환한다', () async {
      final repo = _FakeStudyRepository(
        requestError: const ApiException(
          statusCode: 409,
          serverMessage: '이미 신청했어요.',
        ),
      );
      final bloc = _buildBloc(repo, clock: open);

      bloc.add(const StudyEvent.actionSubmitted());
      await pumpEventQueue();

      expect(bloc.state.result?.success, isFalse);
      expect(bloc.state.result?.message, '이미 신청했어요.');
      expect(bloc.state.actionStatus, StudyActionStatus.ready);
      await bloc.close();
    });

    test('actionEvaluated 는 applied 상태를 시간과 무관하게 유지한다', () async {
      final repo = _FakeStudyRepository();
      final bloc = _buildBloc(repo, clock: open);

      bloc.add(const StudyEvent.actionSubmitted()); // applied
      await pumpEventQueue();

      bloc.add(const StudyEvent.actionEvaluated());
      await pumpEventQueue();

      expect(bloc.state.actionStatus, StudyActionStatus.applied);
      await bloc.close();
    });

    test('대기 중 신청 시간이 되면 actionEvaluated 로 버튼이 활성화된다', () async {
      var now = closed(); // 19:00 KST → closed
      final repo = _FakeStudyRepository();
      final bloc = _buildBloc(repo, clock: () => now);

      expect(bloc.state.actionStatus, StudyActionStatus.closed);

      // 시간이 흘러 신청 가능 시각이 되면(주기 타이머가 쏘는) actionEvaluated 로
      // 별도 사용자 조작 없이 버튼이 활성화된다.
      now = open(); // 20:30 KST → open
      bloc.add(const StudyEvent.actionEvaluated());
      await pumpEventQueue();

      expect(bloc.state.actionStatus, StudyActionStatus.ready);
      await bloc.close();
    });
  });

  group('StudyBloc 목록', () {
    const applicants = [
      StudyApplicant(
        id: 1,
        name: '김민솔',
        studentNumber: 2403,
        grade: 2,
        classNumber: 4,
        number: 3,
        sex: 'WOMAN',
      ),
      StudyApplicant(
        id: 2,
        name: '이재현',
        studentNumber: 1101,
        grade: 1,
        classNumber: 1,
        number: 1,
        sex: 'MAN',
      ),
    ];

    test('applicantsRequested 는 목록을 로드한다', () async {
      final repo = _FakeStudyRepository(applicants: applicants);
      final bloc = _buildBloc(repo, clock: open);

      expect(bloc.state.listStatus, StudyListStatus.initial);

      bloc.add(const StudyEvent.applicantsRequested());
      await pumpEventQueue();

      expect(bloc.state.listStatus, StudyListStatus.loaded);
      expect(bloc.state.applicants, hasLength(2));
      expect(bloc.state.applicantCount, 2);
      await bloc.close();
    });

    test('refresh 재조회는 인디케이터(loading) 없이 refreshing 으로 값만 갱신한다', () async {
      final repo = _FakeStudyRepository(applicants: applicants);
      final bloc = _buildBloc(repo, clock: open);

      final statuses = <StudyListStatus>[];
      final sub = bloc.stream.listen((s) => statuses.add(s.listStatus));

      bloc.add(const StudyEvent.applicantsRequested(refresh: true));
      await pumpEventQueue();

      // 최초 로딩 인디케이터(loading)는 거치지 않고 refreshing → loaded.
      expect(statuses, contains(StudyListStatus.refreshing));
      expect(statuses, isNot(contains(StudyListStatus.loading)));
      expect(bloc.state.listStatus, StudyListStatus.loaded);
      expect(bloc.state.applicants, hasLength(2));

      await sub.cancel();
      await bloc.close();
    });

    test('refresh 실패 시 기존 목록을 유지한 채 error 만 알린다', () async {
      final repo = _FakeStudyRepository(applicants: applicants);
      final bloc = _buildBloc(repo, clock: open);

      // 최초 로드로 목록을 채운다.
      bloc.add(const StudyEvent.applicantsRequested());
      await pumpEventQueue();
      expect(bloc.state.applicants, hasLength(2));

      // 재조회를 실패하도록 fetch 를 던지게 바꾼다.
      repo.fetchError = const ApiException(isNetwork: true);
      bloc.add(const StudyEvent.applicantsRequested(refresh: true));
      await pumpEventQueue();

      expect(bloc.state.listStatus, StudyListStatus.error);
      expect(bloc.state.listError, isNotNull);
      // 기존 목록은 지워지지 않는다.
      expect(bloc.state.applicants, hasLength(2));
      expect(bloc.state.applicantCount, 2);
      await bloc.close();
    });

    test('filtered 는 학년 기준으로 목록을 거른다', () async {
      final repo = _FakeStudyRepository(applicants: applicants);
      final bloc = _buildBloc(repo, clock: open);

      bloc.add(const StudyEvent.applicantsRequested());
      await pumpEventQueue();

      bloc.add(const StudyEvent.filtered(grade: 2));
      await pumpEventQueue();

      expect(bloc.state.applicants, hasLength(1));
      expect(bloc.state.applicants.first.name, '김민솔');
      // 필터는 표시 목록만 줄이고 전체 카운트는 유지한다.
      expect(bloc.state.applicantCount, 2);
      await bloc.close();
    });

    test('refresh 재조회 후에도 적용 중인 필터가 유지된다', () async {
      final repo = _FakeStudyRepository(applicants: applicants);
      final bloc = _buildBloc(repo, clock: open);

      bloc.add(const StudyEvent.applicantsRequested());
      await pumpEventQueue();

      bloc.add(const StudyEvent.filtered(grade: 2));
      await pumpEventQueue();
      expect(bloc.state.applicants, hasLength(1));

      bloc.add(const StudyEvent.applicantsRequested(refresh: true));
      await pumpEventQueue();

      // 재조회로 목록을 다시 불러와도 2학년 필터가 그대로 적용된다.
      expect(bloc.state.applicants, hasLength(1));
      expect(bloc.state.applicants.first.name, '김민솔');
      expect(bloc.state.applicantCount, 2);
      await bloc.close();
    });

    test('신청 성공 후 목록을 자동으로 새로고침한다', () async {
      final repo = _FakeStudyRepository(applicants: applicants);
      final bloc = _buildBloc(repo, clock: open);

      bloc.add(const StudyEvent.applicantsRequested());
      await pumpEventQueue();
      final fetchAfterInitialLoad = repo.fetchCount;

      bloc.add(const StudyEvent.actionSubmitted());
      await pumpEventQueue();

      expect(bloc.state.actionStatus, StudyActionStatus.applied);
      expect(repo.requestCount, 1);
      // 신청 성공 직후 자동 새로고침으로 fetch 가 한 번 더 일어난다.
      expect(repo.fetchCount, fetchAfterInitialLoad + 1);
      await bloc.close();
    });

    test('조회 실패 시 error 상태와 메시지를 담는다', () async {
      final repo = _ThrowingRepository();
      final bloc = StudyBloc(
        getApplicants: GetStudyApplicantsUseCase(repo),
        repository: repo,
        clock: open,
      );

      bloc.add(const StudyEvent.applicantsRequested());
      await pumpEventQueue();

      expect(bloc.state.listStatus, StudyListStatus.error);
      expect(bloc.state.listError, contains('네트워크'));
      await bloc.close();
    });

    test('파싱 오류(Error)에도 무한 로딩에 빠지지 않고 error 상태가 된다', () async {
      final repo = _ParseErrorRepository();
      final bloc = StudyBloc(
        getApplicants: GetStudyApplicantsUseCase(repo),
        repository: repo,
        clock: open,
      );

      bloc.add(const StudyEvent.applicantsRequested());
      await pumpEventQueue();

      expect(bloc.state.listStatus, StudyListStatus.error);
      expect(bloc.state.listError, '목록을 불러오지 못했어요.');
      await bloc.close();
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

/// fetchApplicants 가 네트워크 [ApiException] 을 던지는 저장소.
class _ThrowingRepository implements StudyRepository {
  @override
  Future<List<StudyApplicant>> fetchApplicants() async =>
      throw const ApiException(isNetwork: true);

  @override
  Future<void> requestStudy() async {}

  @override
  Future<void> cancelStudy() async {}
}

/// fetchApplicants 가 응답 스키마 불일치 시의 파싱 오류(Error)를 흉내내는 저장소.
/// Error 는 `on Exception` 을 빠져나가므로, 정규화 없이는 로딩이 풀리지 않는다.
class _ParseErrorRepository implements StudyRepository {
  @override
  Future<List<StudyApplicant>> fetchApplicants() async {
    const dynamic notAList = 42;
    return notAList as List<StudyApplicant>; // throws TypeError
  }

  @override
  Future<void> requestStudy() async {}

  @override
  Future<void> cancelStudy() async {}
}
