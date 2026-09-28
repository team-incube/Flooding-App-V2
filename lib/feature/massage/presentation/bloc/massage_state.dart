import 'package:flooding_v2/feature/massage/domain/enum/massage_action_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enum/gender.dart';
import '../../../member/presentation/models/member_model.dart';

part 'massage_state.freezed.dart';

/// 안마의자 신청자 목록 조회 상태.
///
/// [loading] 은 최초 조회(인디케이터 노출), [refreshing] 은 기존 목록을 유지한
/// 채 백그라운드로 다시 불러오는 재조회 상태(인디케이터 미노출)다.
enum MassageListStatus { initial, loading, refreshing, loaded, error }

/// 신청/취소 1회 결과 — 호출자가 SnackBar 등으로 안내한다.
///
/// 매번 새 인스턴스로 생성해 동일 메시지라도 상태 변화를 구분할 수 있게 한다
/// (BlocListener 가 결과 식별자로 중복 안내를 거른다).
class MassageActionResult {
  MassageActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

/// 안마의자 신청 액션 상태와 신청자 목록 상태를 함께 담는다.
@freezed
abstract class MassageState with _$MassageState {
  const factory MassageState({
    /// 신청 버튼 상태.
    @Default(MassageActionStatus.closed) MassageActionStatus actionStatus,

    /// 직전 신청/취소 결과(1회성 안내용).
    MassageActionResult? result,

    /// 신청자 목록 조회 상태.
    @Default(MassageListStatus.initial) MassageListStatus listStatus,

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
  }) = _MassageState;
}

/// 필터가 하나라도 적용돼 있는지 여부.
extension MassageStateX on MassageState {
  bool get hasActiveFilter =>
      filterGrade != null || filterClassNb != null || filterGender != null;
}

/// 버튼에 표시할 라벨/활성 여부 매핑.
extension MassageActionStatusX on MassageActionStatus {
  String get actionLabel => switch (this) {
    MassageActionStatus.closed => '신청 불가',
    MassageActionStatus.ready => '신청하기',
    MassageActionStatus.applied => '신청취소',
    MassageActionStatus.submitting => '처리 중...',
  };

  bool get actionEnabled =>
      this == MassageActionStatus.ready || this == MassageActionStatus.applied;
}
