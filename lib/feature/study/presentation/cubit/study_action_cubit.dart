import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/study_repository.dart';
import '../../domain/study_request_policy.dart';

/// 자습 신청 버튼의 상태.
enum StudyActionStatus {
  /// 신청 가능 시간이 아님 — 버튼 비활성.
  closed,

  /// 신청 가능 — 누르면 신청.
  ready,

  /// 신청 완료 — 누르면 취소.
  applied,

  /// 신청/취소 요청 처리 중.
  submitting,
}

/// 신청/취소 1회 결과 — 호출자가 SnackBar 등으로 안내한다.
class StudyActionResult {
  const StudyActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

/// 자습 신청/취소 액션과 버튼 상태를 관리한다.
///
/// 시간 정책([StudyRequestPolicy])으로 활성 여부를 판단하고,
/// 누르면 현재 상태에 따라 [StudyRepository.requestStudy] /
/// [StudyRepository.cancelStudy] 를 호출한다.
class StudyActionCubit extends Cubit<StudyActionStatus> {
  StudyActionCubit({
    required StudyRepository repository,
    StudyRequestPolicy policy = const StudyRequestPolicy(),
    DateTime Function() clock = DateTime.now,
  }) : _repository = repository,
       _policy = policy,
       _clock = clock,
       super(StudyActionStatus.closed) {
    evaluate();
  }

  final StudyRepository _repository;
  final StudyRequestPolicy _policy;
  final DateTime Function() _clock;

  /// 현재 시각 기준으로 버튼 활성 상태를 재평가한다.
  /// 이미 신청한 상태(`applied`)는 시간과 무관하게 유지한다(취소 가능).
  void evaluate() {
    if (state == StudyActionStatus.applied ||
        state == StudyActionStatus.submitting) {
      return;
    }
    emit(_openStatus());
  }

  /// 현재 상태에 따라 신청 또는 취소를 수행한다.
  /// 처리할 수 없는 상태(`closed`/`submitting`)면 null 을 반환한다.
  Future<StudyActionResult?> submit() async {
    final wasApplied = state == StudyActionStatus.applied;
    if (state != StudyActionStatus.ready && !wasApplied) return null;

    emit(StudyActionStatus.submitting);
    try {
      if (wasApplied) {
        await _repository.cancelStudy();
        emit(_openStatus());
        return const StudyActionResult(success: true, message: '자습 신청을 취소했어요.');
      }
      await _repository.requestStudy();
      emit(StudyActionStatus.applied);
      return const StudyActionResult(success: true, message: '자습을 신청했어요.');
    } on StudyException catch (e) {
      emit(wasApplied ? StudyActionStatus.applied : _openStatus());
      return StudyActionResult(
        success: false,
        message: e.message ?? '요청을 처리하지 못했어요.',
      );
    }
  }

  StudyActionStatus _openStatus() =>
      _policy.isOpenAt(_clock()) ? StudyActionStatus.ready : StudyActionStatus.closed;
}

/// 버튼에 표시할 라벨/활성 여부 매핑.
extension StudyActionStatusX on StudyActionStatus {
  String get actionLabel => switch (this) {
    StudyActionStatus.closed => '신청 불가',
    StudyActionStatus.ready => '신청하기',
    StudyActionStatus.applied => '신청취소',
    StudyActionStatus.submitting => '처리 중...',
  };

  bool get actionEnabled =>
      this == StudyActionStatus.ready || this == StudyActionStatus.applied;
}
