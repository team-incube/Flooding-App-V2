import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_selection_event.freezed.dart';

@freezed
class MemberSelectionEvent with _$MemberSelectionEvent {
  /// [id] 는 탭한 학생의 서버 ID. [isAttended] 는 현재 출석 상태 — 이미
  /// 선택된 항목과 상태가 다르면(체크인 대상/체크아웃 대상 혼합) 무시된다.
  const factory MemberSelectionEvent.check({
    required int id,
    required bool isAttended,
  }) = _Check;

  /// 선택 목록을 초기화한다(체크인 등 액션 완료 후 호출).
  const factory MemberSelectionEvent.clear() = _Clear;
}
