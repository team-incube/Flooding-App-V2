import 'package:flooding_v2/feature/study/domain/enum/study_action_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enum/gender.dart';
import '../../../member/presentation/models/member_model.dart';

part 'study_state.freezed.dart';

/// 자습 신청자 목록 조회 상태.
///
/// [loading] 은 최초 조회(인디케이터 노출), [refreshing] 은 기존 목록을 유지한
/// 채 백그라운드로 다시 불러오는 재조회 상태(인디케이터 미노출)다.
enum StudyListStatus { initial, loading, refreshing, loaded, error }

/// 신청/취소 1회 결과 — 호출자가 SnackBar 등으로 안내한다.
///
/// 매번 새 인스턴스로 생성해 동일 메시지라도 상태 변화를 구분할 수 있게 한다
/// (BlocListener 가 결과 식별자로 중복 안내를 거른다).
class StudyActionResult {
  StudyActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

/// 자습 신청 액션 상태와 신청자 목록 상태를 함께 담는다.
@freezed
abstract class StudyState with _$StudyState {
  const factory StudyState({
    /// 신청 버튼 상태.
    @Default(StudyActionStatus.closed) StudyActionStatus actionStatus,

    /// 직전 신청/취소 결과(1회성 안내용).
    StudyActionResult? result,

    /// 신청자 목록 조회 상태.
    @Default(StudyListStatus.initial) StudyListStatus listStatus,

    /// 화면에 표시할 신청자 목록(필터 적용 결과).
    @Default(<MemberModel>[]) List<MemberModel> applicants,

    /// 전체 신청 인원 수 — 필터와 무관한 총원(카운트 카드 표시용).
    @Default(0) int applicantCount,

    /// 목록 조회 실패 메시지.
    String? listError,

    /// 현재 적용 중인 필터(학년) — 재조회 시 재적용한다.
    int? filterGrade,

    /// 현재 적용 중인 필터(반).
    int? filterClassNb,

    /// 현재 적용 중인 필터(성별).
    Gender? filterGender,
  }) = _StudyState;
}

/// 필터가 하나라도 적용돼 있는지 여부.
extension StudyStateX on StudyState {
  bool get hasActiveFilter =>
      filterGrade != null || filterClassNb != null || filterGender != null;
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
