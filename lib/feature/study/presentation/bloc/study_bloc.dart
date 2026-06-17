import 'dart:async';

import 'package:flooding_v2/feature/study/domain/enum/study_action_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/enum/gender.dart';
import '../../../member/presentation/models/member_model.dart';
import '../../domain/repositories/study_repository.dart';
import '../../domain/repositories/study_request_policy.dart';
import '../../domain/usecases/get_study_applicants_usecase.dart';
import 'study_event.dart';
import 'study_state.dart';

class StudyBloc extends Bloc<StudyEvent, StudyState> {
  StudyBloc({
    required GetStudyApplicantsUseCase getApplicants,
    required StudyRepository repository,
    StudyRequestPolicy policy = const StudyRequestPolicy(),
    DateTime Function() clock = DateTime.now,
  }) : _getApplicants = getApplicants,
       _repository = repository,
       _policy = policy,
       _clock = clock,
       super(StudyState(actionStatus: _openStatusFor(policy, clock))) {
    on<StudyEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        applicantsRequested: (refresh) =>
            _onApplicantsRequested(emit, refresh: refresh),
        filtered: (grade, classNb, gender) =>
            _onFiltered(emit, grade, classNb, gender),
        actionEvaluated: () => _onActionEvaluated(emit),
        actionSubmitted: () => _onActionSubmitted(emit),
      );
    });
  }

  final GetStudyApplicantsUseCase _getApplicants;
  final StudyRepository _repository;
  final StudyRequestPolicy _policy;
  final DateTime Function() _clock;

  List<MemberModel> _allApplicants = [];

  // ── 목록 조회 ─────────────────────────────────────────────

  Future<void> _onApplicantsRequested(
    Emitter<StudyState> emit, {
    required bool refresh,
  }) async {
    // 최초 조회만 인디케이터(loading)를 띄운다. 재조회(refresh)는 기존 목록을
    // 유지한 채 refreshing 상태로 두어 화면 깜빡임 없이 값만 갱신한다.
    emit(
      state.copyWith(
        listStatus: refresh
            ? StudyListStatus.refreshing
            : StudyListStatus.loading,
        listError: null,
      ),
    );
    try {
      _allApplicants = await _getApplicants();
      emit(
        state.copyWith(
          listStatus: StudyListStatus.loaded,
          applicants: _allApplicants,
          applicantCount: _allApplicants.length,
        ),
      );
    } catch (e, s) {
      // Exception 뿐 아니라 Error(파싱 TypeError 등)까지 모두 잡아, 어떤
      // 실패에도 로딩이 풀리도록 한다 — 무한 로딩 스피너 방지.
      Logger.e('자습 신청자 목록 조회 실패', tag: 'STUDY', error: e, stackTrace: s);
      // 재조회 실패 시에는 기존 목록을 지우지 않고 사유만 안내한다.
      if (refresh) {
        emit(
          state.copyWith(
            listStatus: StudyListStatus.error,
            listError: _messageOf(e),
          ),
        );
        return;
      }
      _allApplicants = [];
      emit(
        state.copyWith(
          listStatus: StudyListStatus.error,
          applicants: const [],
          applicantCount: 0,
          listError: _messageOf(e),
        ),
      );
    }
  }

  void _onFiltered(
    Emitter<StudyState> emit,
    int? grade,
    int? classNb,
    Gender? gender,
  ) {
    if (_allApplicants.isEmpty) return;

    Iterable<MemberModel> filtered = _allApplicants;
    if (grade != null) {
      filtered = filtered.where((m) => grade == m.schoolNb ~/ 1000);
    }
    if (classNb != null) {
      filtered = filtered.where((m) => classNb == (m.schoolNb ~/ 100) % 10);
    }
    if (gender != null) {
      filtered = filtered.where((m) => gender == m.gender);
    }

    emit(state.copyWith(applicants: filtered.toList()));
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

  // ── 신청/취소 액션 ─────────────────────────────────────────

  /// 이미 신청한 상태(`applied`)는 시간과 무관하게 유지한다(취소 가능).
  void _onActionEvaluated(Emitter<StudyState> emit) {
    if (state.actionStatus == StudyActionStatus.applied ||
        state.actionStatus == StudyActionStatus.submitting) {
      return;
    }
    emit(state.copyWith(actionStatus: _openStatus()));
  }

  /// 처리할 수 없는 상태(`closed`/`submitting`)면 아무 것도 하지 않는다.
  Future<void> _onActionSubmitted(Emitter<StudyState> emit) async {
    final wasApplied = state.actionStatus == StudyActionStatus.applied;
    if (state.actionStatus != StudyActionStatus.ready && !wasApplied) return;

    emit(state.copyWith(actionStatus: StudyActionStatus.submitting));
    try {
      if (wasApplied) {
        await _repository.cancelStudy();
        emit(
          state.copyWith(
            actionStatus: _openStatus(),
            result: StudyActionResult(success: true, message: '자습 신청을 취소했어요.'),
          ),
        );
        return;
      }
      await _repository.requestStudy();
      emit(
        state.copyWith(
          actionStatus: StudyActionStatus.applied,
          result: StudyActionResult(success: true, message: '자습을 신청했어요.'),
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          actionStatus: wasApplied ? StudyActionStatus.applied : _openStatus(),
          result: StudyActionResult(success: false, message: e.message),
        ),
      );
    } catch (e, s) {
      // 파싱 오류 등 ApiException 이 아닌 실패에도 submitting 을 풀어준다.
      Logger.e('자습 신청/취소 실패', tag: 'STUDY', error: e, stackTrace: s);
      emit(
        state.copyWith(
          actionStatus: wasApplied ? StudyActionStatus.applied : _openStatus(),
          result: StudyActionResult(
            success: false,
            message: '요청을 처리하지 못했어요.',
          ),
        ),
      );
    }
  }

  StudyActionStatus _openStatus() => _openStatusFor(_policy, _clock);

  static StudyActionStatus _openStatusFor(
    StudyRequestPolicy policy,
    DateTime Function() clock,
  ) => policy.isOpenAt(clock())
      ? StudyActionStatus.ready
      : StudyActionStatus.closed;
}
