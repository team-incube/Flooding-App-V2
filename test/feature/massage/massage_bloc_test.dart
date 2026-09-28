import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/feature/massage/data/models/massage_applicant.dart';
import 'package:flooding_v2/feature/massage/domain/repositories/massage_repository.dart';
import 'package:flooding_v2/feature/massage/domain/usecases/get_massage_applicants_usecase.dart';
import 'package:flooding_v2/feature/massage/presentation/bloc/massage_bloc.dart';
import 'package:flooding_v2/feature/massage/presentation/bloc/massage_event.dart';

class _FakeMassageRepository implements MassageRepository {
  _FakeMassageRepository({this.applicants = const []});

  final List<MassageApplicant> applicants;
  int fetchCount = 0;

  @override
  Future<List<MassageApplicant>> fetchApplicants() async {
    fetchCount++;
    return applicants;
  }

  @override
  Future<void> requestMassage() async {}

  @override
  Future<void> cancelMassage() async {}
}

MassageBloc _buildBloc(
  _FakeMassageRepository repo, {
  required DateTime Function() clock,
  Duration tick = const Duration(milliseconds: 10),
}) => MassageBloc(
  getApplicants: GetMassageApplicantsUseCase(repo),
  repository: repo,
  clock: clock,
  tick: tick,
);

void main() {
  // 정책은 KST(UTC+9) 기준이므로 시계는 UTC 로 고정해 결정적으로 만든다.
  // 11:30 UTC == 20:30 KST(open), 10:00 UTC == 19:00 KST(beforeOpen).
  DateTime open() => DateTime.utc(2026, 6, 16, 11, 30);
  DateTime closed() => DateTime.utc(2026, 6, 16, 10, 0);

  const applicants = [
    MassageApplicant(name: '김민솔', studentNumber: 2403),
  ];

  group('MassageBloc 현황 폴링', () {
    test('신청 가능 시간대에는 현황을 주기적으로 폴링한다(refresh)', () async {
      final repo = _FakeMassageRepository(applicants: applicants);
      final bloc = _buildBloc(repo, clock: open);

      bloc.add(const MassageEvent.applicantsRequested());
      await pumpEventQueue();
      final afterInitial = repo.fetchCount;

      // 주기 타이머가 몇 번 돌 시간을 준다.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await pumpEventQueue();

      // 시간대가 열려 있으면 사용자 조작 없이도 fetch 가 더 일어난다.
      expect(repo.fetchCount, greaterThan(afterInitial));
      // 폴링은 기존 목록을 유지한 채 값만 갱신한다(빈 목록으로 깜빡이지 않음).
      expect(bloc.state.applicantCount, 1);
      await bloc.close();
    });

    test('신청 시간이 아니면 폴링하지 않는다', () async {
      final repo = _FakeMassageRepository(applicants: applicants);
      final bloc = _buildBloc(repo, clock: closed);

      bloc.add(const MassageEvent.applicantsRequested());
      await pumpEventQueue();
      final afterInitial = repo.fetchCount;

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await pumpEventQueue();

      // 시간대 밖에서는 추가 호출이 없어야 한다.
      expect(repo.fetchCount, afterInitial);
      await bloc.close();
    });
  });
}
