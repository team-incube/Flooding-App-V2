import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/wake_up_music.dart';
import '../../domain/enum/music_sort.dart';

part 'music_state.freezed.dart';

/// 기상음악 목록 조회 상태.
///
/// [loading] 은 최초 조회(인디케이터 노출), [refreshing] 은 기존 목록을 유지한
/// 채 백그라운드로 다시 불러오는 재조회 상태(인디케이터 미노출)다.
enum MusicListStatus { initial, loading, refreshing, loaded, error }

/// 신청 1회 결과 — 호출자가 SnackBar 등으로 안내한다.
///
/// 매번 새 인스턴스로 생성해 동일 메시지라도 상태 변화를 구분할 수 있게 한다
/// (BlocListener 가 결과 식별자로 중복 안내를 거른다).
class MusicApplyResult {
  MusicApplyResult({required this.success, required this.message});

  final bool success;
  final String message;
}

@freezed
abstract class MusicState with _$MusicState {
  const factory MusicState({
    /// 목록 조회 상태.
    @Default(MusicListStatus.initial) MusicListStatus listStatus,

    /// 화면에 표시할 곡 목록(검색어 적용 결과).
    @Default(<WakeUpMusic>[]) List<WakeUpMusic> musics,

    /// 검색어와 무관한 전체 신청 곡 수(빈 상태 문구 구분·카운트용).
    @Default(0) int totalCount,

    /// 현재 적용 중인 검색어 — 재조회 시 재적용한다.
    @Default('') String query,

    /// 목록 조회 실패 메시지.
    String? listError,

    /// 신청 요청 처리 중 여부.
    @Default(false) bool isSubmitting,

    /// 직전 신청 결과(1회성 안내용).
    MusicApplyResult? applyResult,

    /// 직전 좋아요 토글 실패 결과(1회성 안내용). 성공 시엔 설정하지 않는다.
    MusicApplyResult? likeResult,

    /// 현재 조회 정렬 기준.
    @Default(MusicSort.time) MusicSort sort,

    /// 현재 조회 날짜 — null 이면 서버 기본(당일).
    DateTime? date,
  }) = _MusicState;
}
