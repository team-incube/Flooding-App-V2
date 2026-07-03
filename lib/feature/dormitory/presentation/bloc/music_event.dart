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
}
