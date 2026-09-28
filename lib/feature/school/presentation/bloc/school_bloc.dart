import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/homebase_member.dart';
import '../../domain/homebase_seat.dart';
import '../../domain/mapper/homebase_reservation_mapper.dart';
import '../../domain/repositories/school_repository.dart';
import 'school_event.dart';
import 'school_state.dart';

class SchoolBloc extends Bloc<SchoolEvent, SchoolState> {
  SchoolBloc({required SchoolRepository repository})
    : _repository = repository,
      super(const SchoolState()) {
    on<SchoolEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        reservationsRequested: (refresh) =>
            _onReservationsRequested(emit, refresh: refresh),
        reservationCreated: (floor, tableNumber, periods, reason, members) =>
            _onReservationCreated(
              emit,
              floor: floor,
              tableNumber: tableNumber,
              periods: periods,
              reason: reason,
              members: members,
            ),
        reservationDeleted: (reservationId) =>
            _onReservationDeleted(emit, reservationId),
      );
    });
  }

  final SchoolRepository _repository;

  // ── 목록 조회 ─────────────────────────────────────────────

  Future<void> _onReservationsRequested(
    Emitter<SchoolState> emit, {
    required bool refresh,
  }) async {
    // 최초 조회만 인디케이터(loading). 재조회(refresh)는 기존 목록을 유지한
    // 채 refreshing 상태로 두어 화면 깜빡임 없이 값만 갱신한다.
    emit(
      state.copyWith(
        listStatus: refresh
            ? SchoolListStatus.refreshing
            : SchoolListStatus.loading,
        listError: null,
      ),
    );
    try {
      final reservations = await _repository.fetchReservations(DateTime.now());
      emit(
        state.copyWith(
          listStatus: SchoolListStatus.loaded,
          reservations: reservations
              .map(HomebaseReservationMapper.toModel)
              .toList(),
        ),
      );
    } catch (e, s) {
      // Exception 뿐 아니라 Error(파싱 TypeError 등)까지 모두 잡아, 어떤
      // 실패에도 로딩이 풀리도록 한다 — 무한 로딩 스피너 방지.
      Logger.e('홈베이스 예약 목록 조회 실패', tag: 'SCHOOL', error: e, stackTrace: s);
      // 재조회 실패 시에는 기존 목록을 지우지 않고 사유만 안내한다.
      if (refresh) {
        emit(
          state.copyWith(
            listStatus: SchoolListStatus.error,
            listError: _messageOf(e),
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          listStatus: SchoolListStatus.error,
          reservations: const [],
          listError: _messageOf(e),
        ),
      );
    }
  }

  // ── 예약 생성 ─────────────────────────────────────────────

  Future<void> _onReservationCreated(
    Emitter<SchoolState> emit, {
    required int floor,
    required int tableNumber,
    required Set<int> periods,
    required String reason,
    required List<HomebaseMember> members,
  }) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, result: null));
    try {
      await _repository.createReservation(
        homebaseId: HomebaseSeat.toId(floor: floor, tableNumber: tableNumber),
        date: DateTime.now(),
        startPeriod: periods.reduce((a, b) => a < b ? a : b),
        endPeriod: periods.reduce((a, b) => a > b ? a : b),
        reason: reason,
        members: members,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          result: SchoolActionResult(success: true, message: '홈베이스를 예약했어요.'),
        ),
      );
      // 생성 결과가 목록에 즉시 반영되도록 자동 새로고침한다.
      add(const SchoolEvent.reservationsRequested(refresh: true));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          result: SchoolActionResult(success: false, message: e.message),
        ),
      );
    } catch (e, s) {
      Logger.e('홈베이스 예약 생성 실패', tag: 'SCHOOL', error: e, stackTrace: s);
      emit(
        state.copyWith(
          isSubmitting: false,
          result: SchoolActionResult(success: false, message: '예약을 처리하지 못했어요.'),
        ),
      );
    }
  }

  // ── 예약 삭제 ─────────────────────────────────────────────

  Future<void> _onReservationDeleted(
    Emitter<SchoolState> emit,
    int reservationId,
  ) async {
    try {
      await _repository.deleteReservation(reservationId);
      emit(
        state.copyWith(
          result: SchoolActionResult(success: true, message: '예약을 삭제했어요.'),
        ),
      );
      // 삭제 결과가 목록에 즉시 반영되도록 자동 새로고침한다.
      add(const SchoolEvent.reservationsRequested(refresh: true));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          result: SchoolActionResult(success: false, message: e.message),
        ),
      );
    } catch (e, s) {
      Logger.e('홈베이스 예약 삭제 실패', tag: 'SCHOOL', error: e, stackTrace: s);
      emit(
        state.copyWith(
          result: SchoolActionResult(success: false, message: '삭제를 처리하지 못했어요.'),
        ),
      );
    }
  }

  String _messageOf(Object e) {
    // ApiException 은 사용자용 메시지를 직접 제공한다.
    if (e is ApiException) return e.message;
    final raw = e.toString();
    final stripped = raw.startsWith('Exception: ')
        ? raw.substring('Exception: '.length)
        : raw;
    // Error(TypeError 등)의 raw 문자열은 사용자에게 부적절하므로 일반 문구로.
    if (e is! Exception || stripped.isEmpty) return '목록을 불러오지 못했어요.';
    return stripped;
  }
}
