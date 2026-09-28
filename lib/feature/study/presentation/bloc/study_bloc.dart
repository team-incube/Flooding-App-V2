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
    Duration tick = const Duration(seconds: 30),
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
        checkInRequested: (userIds) =>
            _onAttendanceAction(emit, userIds, _repository.checkIn, '체크인'),
        checkOutRequested: (userIds) =>
            _onAttendanceAction(emit, userIds, _repository.checkOut, '체크아웃'),
      );
    });

    // 신청 시작/마감 시각이 실시간으로 지나면 버튼 활성 상태가 저절로 바뀌도록
    // 주기적으로 재평가한다(앱을 20:00 이전부터 켜둬도 시간이 되면 활성화).
    // 또한 신청 가능 시간대에는 현황(신청자 수)을 주기적으로 폴링한다 — 다른
    // 학생의 신청/취소가 홈·기숙사 카운트 카드에 곧 반영되도록. 시간대 밖에서는
    // 인원이 바뀌지 않으므로 폴링하지 않아 불필요한 호출을 막는다.
    _ticker = Timer.periodic(tick, (_) {
      if (isClosed) return;
      add(const StudyEvent.actionEvaluated());
      if (_policy.isOpenAt(_clock())) {
        add(const StudyEvent.applicantsRequested(refresh: true));
      }
    });
  }

  final GetStudyApplicantsUseCase _getApplicants;
  final StudyRepository _repository;
  final StudyRequestPolicy _policy;
  final DateTime Function() _clock;

  Timer? _ticker;
  List<MemberModel> _allApplicants = [];

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

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
          // 재조회로 목록이 갱신돼도 현재 적용 중인 필터를 유지한다.
          applicants: _applyFilter(_allApplicants, state),
          applicantCount: _allApplicants.length,
          // 화면 진입/새로고침 시점에 버튼 활성 상태도 함께 재평가한다.
          actionStatus: _reevaluatedStatus(),
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
    // 선택한 필터를 상태에 보관해 두면, 이후 재조회 때도 동일 필터가 재적용된다.
    final next = state.copyWith(
      filterGrade: grade,
      filterClassNb: classNb,
      filterGender: gender,
    );
    emit(next.copyWith(applicants: _applyFilter(_allApplicants, next)));
  }

  /// [state] 에 보관된 필터(학년/반/성별)를 [all] 에 적용한 결과를 반환한다.
  List<MemberModel> _applyFilter(List<MemberModel> all, StudyState state) {
    Iterable<MemberModel> filtered = all;
    final grade = state.filterGrade;
    final classNb = state.filterClassNb;
    final gender = state.filterGender;
    if (grade != null) {
      filtered = filtered.where((m) => grade == m.schoolNb ~/ 1000);
    }
    if (classNb != null) {
      filtered = filtered.where((m) => classNb == (m.schoolNb ~/ 100) % 10);
    }
    if (gender != null) {
      filtered = filtered.where((m) => gender == m.gender);
    }
    return filtered.toList();
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
    emit(state.copyWith(actionStatus: _reevaluatedStatus()));
  }

  /// 현재 시각 기준 버튼 활성 상태. 단, `applied`/`submitting` 은 시간과
  /// 무관하게 그대로 유지한다(신청 완료/처리 중 상태 보호).
  StudyActionStatus _reevaluatedStatus() {
    final current = state.actionStatus;
    if (current == StudyActionStatus.applied ||
        current == StudyActionStatus.submitting) {
      return current;
    }
    return _openStatus();
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
        // 취소 결과가 목록에 즉시 반영되도록 자동 새로고침한다.
        add(const StudyEvent.applicantsRequested(refresh: true));
        return;
      }
      await _repository.requestStudy();
      emit(
        state.copyWith(
          actionStatus: StudyActionStatus.applied,
          result: StudyActionResult(success: true, message: '자습을 신청했어요.'),
        ),
      );
      // 신청 결과(본인 이름)가 목록에 즉시 반영되도록 자동 새로고침한다.
      add(const StudyEvent.applicantsRequested(refresh: true));
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
          result: StudyActionResult(success: false, message: '요청을 처리하지 못했어요.'),
        ),
      );
    }
  }

  // ── 체크인/체크아웃(사감 전용) ─────────────────────────────

  /// [action] 을 [userIds] 각각에 병렬로 적용하고, 결과를 [StudyActionResult]
  /// 로 알린 뒤 목록을 새로고침한다(출석 상태를 즉시 반영).
  Future<void> _onAttendanceAction(
    Emitter<StudyState> emit,
    List<int> userIds,
    Future<void> Function(int userId) action,
    String actionLabel,
  ) async {
    final errors = await Future.wait(
      userIds.map((userId) async {
        try {
          await action(userId);
          return null;
        } on ApiException catch (e) {
          return e.message;
        } catch (e, s) {
          Logger.e('자습 $actionLabel 실패', tag: 'STUDY', error: e, stackTrace: s);
          return '$actionLabel에 실패했어요.';
        }
      }),
    );
    final successCount = errors.where((e) => e == null).length;
    final lastError = errors.lastWhere((e) => e != null, orElse: () => null);

    final message = successCount == userIds.length
        ? '$successCount명 $actionLabel 완료했어요.'
        : '$successCount/${userIds.length}명만 $actionLabel됐어요. ${lastError ?? ''}';
    emit(
      state.copyWith(
        result: StudyActionResult(
          success: successCount == userIds.length,
          message: message,
          isAttendanceAction: true,
        ),
      ),
    );
  }

  StudyActionStatus _openStatus() => _openStatusFor(_policy, _clock);

  static StudyActionStatus _openStatusFor(
    StudyRequestPolicy policy,
    DateTime Function() clock,
  ) => policy.isOpenAt(clock())
      ? StudyActionStatus.ready
      : StudyActionStatus.closed;
}
