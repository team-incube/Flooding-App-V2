import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/core/network/api_exception.dart';
import 'package:flooding_v2/feature/school/data/models/homebase_member.dart';
import 'package:flooding_v2/feature/school/data/models/homebase_reservation.dart';
import 'package:flooding_v2/feature/school/domain/repositories/school_repository.dart';
import 'package:flooding_v2/feature/school/presentation/bloc/school_bloc.dart';
import 'package:flooding_v2/feature/school/presentation/bloc/school_event.dart';
import 'package:flooding_v2/feature/school/presentation/bloc/school_state.dart';

class _FakeSchoolRepository implements SchoolRepository {
  _FakeSchoolRepository({
    List<HomebaseReservation> reservations = const [],
    this.createError,
  }) : _reservations = reservations;

  List<HomebaseReservation> _reservations;
  Object? createError;
  int fetchCount = 0;
  int? lastDeletedId;
  int? lastCreatedHomebaseId;

  @override
  Future<List<HomebaseReservation>> fetchReservations(DateTime date) async {
    fetchCount++;
    return _reservations;
  }

  @override
  Future<void> createReservation({
    required int homebaseId,
    required DateTime date,
    required int startPeriod,
    required int endPeriod,
    required String reason,
    required List<HomebaseMember> members,
  }) async {
    lastCreatedHomebaseId = homebaseId;
    if (createError != null) throw createError!;
    _reservations = [
      ..._reservations,
      HomebaseReservation(
        id: 1,
        reservationDate: '2026-08-14',
        startPeriod: startPeriod,
        endPeriod: endPeriod,
        reason: reason,
        homebaseId: homebaseId,
        members: members,
      ),
    ];
  }

  @override
  Future<void> deleteReservation(int reservationId) async {
    lastDeletedId = reservationId;
    _reservations = [
      for (final r in _reservations)
        if (r.id != reservationId) r,
    ];
  }
}

void main() {
  group('SchoolBloc 목록 조회', () {
    test('층 2 테이블 1 좌석(homebaseId 1)을 화면 표시용 모델로 매핑한다', () async {
      final repo = _FakeSchoolRepository(
        reservations: const [
          HomebaseReservation(
            id: 10,
            reservationDate: '2026-08-14',
            startPeriod: 8,
            endPeriod: 9,
            reason: '스터디',
            homebaseId: 1,
            members: [HomebaseMember(studentNumber: '2403', name: '김민솔')],
          ),
        ],
      );
      final bloc = SchoolBloc(repository: repo);

      bloc.add(const SchoolEvent.reservationsRequested());
      await pumpEventQueue();

      expect(bloc.state.listStatus, SchoolListStatus.loaded);
      expect(bloc.state.reservations, hasLength(1));
      final model = bloc.state.reservations.single;
      expect(model.floor, 2);
      expect(model.tableNumber, 1);
      expect(model.periods, [8, 9]);
      expect(model.students.single.schoolNb, 2403);
      await bloc.close();
    });

    test('조회 실패 시 에러 상태와 메시지를 노출한다', () async {
      final repo = _FailingFetchRepository();
      final bloc = SchoolBloc(repository: repo);

      bloc.add(const SchoolEvent.reservationsRequested());
      await pumpEventQueue();

      expect(bloc.state.listStatus, SchoolListStatus.error);
      expect(bloc.state.reservations, isEmpty);
      await bloc.close();
    });
  });

  group('SchoolBloc 예약 생성', () {
    test('층·테이블 선택을 homebaseId 로 변환해 생성을 요청하고 목록을 새로고침한다', () async {
      final repo = _FakeSchoolRepository();
      final bloc = SchoolBloc(repository: repo);

      bloc.add(
        SchoolEvent.reservationCreated(
          floor: 3,
          tableNumber: 2,
          periods: const {9, 8, 10},
          reason: '스터디',
          members: const [HomebaseMember(studentNumber: '2403', name: '김민솔')],
        ),
      );
      await pumpEventQueue();

      // 층 3 테이블 2 → id 6 ((3-2)*4 + 2).
      expect(repo.lastCreatedHomebaseId, 6);
      expect(bloc.state.isSubmitting, isFalse);
      expect(bloc.state.result?.success, isTrue);
      // 생성 성공 후 자동 새로고침으로 조회가 1회 더 일어난다.
      expect(repo.fetchCount, 1);
      await bloc.close();
    });

    test('생성 실패 시 서버 메시지를 결과에 담고 제출 상태를 되돌린다', () async {
      final repo = _FakeSchoolRepository(
        createError: const ApiException.message('정원을 초과했습니다.'),
      );
      final bloc = SchoolBloc(repository: repo);

      bloc.add(
        SchoolEvent.reservationCreated(
          floor: 2,
          tableNumber: 1,
          periods: const {8},
          reason: '스터디',
          members: const [HomebaseMember(studentNumber: '2403', name: '김민솔')],
        ),
      );
      await pumpEventQueue();

      expect(bloc.state.isSubmitting, isFalse);
      expect(bloc.state.result?.success, isFalse);
      expect(bloc.state.result?.message, '정원을 초과했습니다.');
      await bloc.close();
    });
  });

  group('SchoolBloc 예약 삭제', () {
    test('삭제 후 목록을 새로고침한다', () async {
      final repo = _FakeSchoolRepository(
        reservations: const [
          HomebaseReservation(
            id: 10,
            reservationDate: '2026-08-14',
            startPeriod: 8,
            endPeriod: 8,
            reason: '스터디',
            homebaseId: 1,
          ),
        ],
      );
      final bloc = SchoolBloc(repository: repo);

      bloc.add(const SchoolEvent.reservationDeleted(reservationId: 10));
      await pumpEventQueue();

      expect(repo.lastDeletedId, 10);
      expect(bloc.state.result?.success, isTrue);
      expect(bloc.state.reservations, isEmpty);
      await bloc.close();
    });
  });
}

class _FailingFetchRepository implements SchoolRepository {
  @override
  Future<List<HomebaseReservation>> fetchReservations(DateTime date) async {
    throw const ApiException.message('목록을 불러오지 못했어요.');
  }

  @override
  Future<void> createReservation({
    required int homebaseId,
    required DateTime date,
    required int startPeriod,
    required int endPeriod,
    required String reason,
    required List<HomebaseMember> members,
  }) async {}

  @override
  Future<void> deleteReservation(int reservationId) async {}
}
