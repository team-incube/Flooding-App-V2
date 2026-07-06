import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/enum/music_sort.dart';

part 'music_event.freezed.dart';

@freezed
class MusicEvent with _$MusicEvent {
  /// 기상음악 목록을 (재)조회한다.
  ///
  /// [refresh] 가 true 면 재조회로 간주해 로딩 인디케이터를 띄우지 않고
  /// 기존 목록을 유지한 채 값만 갱신한다(최초 조회만 인디케이터 노출).
  /// [date]/[sort] 를 주면 조회 조건을 갱신해 이후 재조회에도 유지된다.
  const factory MusicEvent.listRequested({
    @Default(false) bool refresh,
    DateTime? date,
    MusicSort? sort,
  }) = _ListRequested;

  /// [musicUrl] 로 기상음악을 신청한다.
  const factory MusicEvent.applied(String musicUrl) = _Applied;

  /// 노래 제목·신청자 이름으로 목록을 검색(필터)한다.
  ///
  /// 빈 문자열이면 전체 목록을 표시한다. 검색어는 상태에 보관돼
  /// 재조회(신청 후 새로고침 등)에도 동일 필터가 유지된다.
  const factory MusicEvent.searched(String query) = _Searched;

  /// [musicId] 곡의 좋아요를 토글한다(현재 상태 기준으로 좋아요/취소).
  const factory MusicEvent.likeToggled(int musicId) = _LikeToggled;

  /// [musicId] 곡의 기상음악 신청을 취소한다(본인 신청 곡만).
  const factory MusicEvent.cancelRequested(int musicId) = _CancelRequested;
}
