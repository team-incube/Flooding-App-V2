import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/wake_up_music.dart';
import '../../domain/enum/music_sort.dart';
import '../../domain/models/music_sse_event.dart';
import '../../domain/repositories/music_repository.dart';
import 'music_event.dart';
import 'music_state.dart';

/// 기상음악 목록 조회·신청을 담당하는 Bloc.
class MusicBloc extends Bloc<MusicEvent, MusicState> {
  MusicBloc({required MusicRepository repository})
    : _repository = repository,
      super(const MusicState()) {
    on<MusicEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        listRequested: (refresh, date, sort) =>
            _onListRequested(emit, refresh: refresh, date: date, sort: sort),
        applied: (musicUrl) => _onApplied(emit, musicUrl),
        searched: (query) => _onSearched(emit, query),
        likeToggled: (musicId) => _onLikeToggled(emit, musicId),
        cancelRequested: (musicId) => _onCancelRequested(emit, musicId),
        subscriptionStarted: () => _onSubscriptionStarted(),
        sseReceived: (sseEvent) => _onSseReceived(emit, sseEvent),
      );
    });
  }

  final MusicRepository _repository;

  /// 검색어 적용 전 전체 목록 — 필터는 이 목록에 다시 적용한다.
  List<WakeUpMusic> _allMusics = [];

  /// 실시간(SSE) 구독. 재구독 시 이전 구독을 취소하고 새로 연결한다.
  StreamSubscription<MusicSseEvent>? _sseSub;

  /// 연결 끊김 후 재연결 예약 타이머.
  Timer? _reconnectTimer;

  /// close 이후 재연결이 다시 예약되지 않도록 막는 플래그.
  bool _closed = false;

  // ── 목록 조회 ─────────────────────────────────────────────

  Future<void> _onListRequested(
    Emitter<MusicState> emit, {
    required bool refresh,
    DateTime? date,
    MusicSort? sort,
  }) async {
    // 조회 조건(날짜/정렬)이 함께 오면 상태에 반영해 이후 재조회에도 유지한다.
    final nextSort = sort ?? state.sort;
    final nextDate = date ?? state.date;

    // 최초 조회만 인디케이터(loading). 재조회(refresh)는 기존 목록을 유지한 채
    // refreshing 상태로 두어 화면 깜빡임 없이 값만 갱신한다.
    emit(
      state.copyWith(
        listStatus: refresh
            ? MusicListStatus.refreshing
            : MusicListStatus.loading,
        sort: nextSort,
        date: nextDate,
        listError: null,
      ),
    );
    try {
      _allMusics = await _repository.fetchMusicList(
        date: nextDate,
        sort: nextSort,
      );
      emit(
        state.copyWith(
          listStatus: MusicListStatus.loaded,
          // 재조회로 목록이 갱신돼도 현재 검색어를 유지해 재적용한다.
          musics: _applyFilter(_allMusics, state.query),
          totalCount: _allMusics.length,
        ),
      );
    } catch (e, s) {
      // Exception 뿐 아니라 Error(파싱 TypeError 등)까지 모두 잡아, 어떤
      // 실패에도 로딩이 풀리도록 한다 — 무한 로딩 스피너 방지.
      Logger.e('기상음악 목록 조회 실패', tag: 'MUSIC', error: e, stackTrace: s);
      // 재조회 실패 시에는 기존 목록을 지우지 않고 사유만 안내한다.
      if (refresh) {
        emit(
          state.copyWith(
            listStatus: MusicListStatus.error,
            listError: _messageOf(e),
          ),
        );
        return;
      }
      _allMusics = [];
      emit(
        state.copyWith(
          listStatus: MusicListStatus.error,
          musics: const [],
          totalCount: 0,
          listError: _messageOf(e),
        ),
      );
    }
  }

  // ── 검색(필터) ─────────────────────────────────────────────

  void _onSearched(Emitter<MusicState> emit, String query) {
    // 검색어를 상태에 보관해 이후 재조회에도 동일 필터가 재적용되도록 한다.
    emit(
      state.copyWith(query: query, musics: _applyFilter(_allMusics, query)),
    );
  }

  // ── 좋아요 토글 ────────────────────────────────────────────

  Future<void> _onLikeToggled(Emitter<MusicState> emit, int musicId) async {
    final index = _allMusics.indexWhere((m) => m.id == musicId);
    if (index == -1) return;

    final original = _allMusics[index];
    final willLike = !original.isLiked;
    final nextCount = willLike
        ? original.likeCount + 1
        : (original.likeCount > 0 ? original.likeCount - 1 : 0);

    // 낙관적 업데이트 — 하트를 즉시 토글하고, 실패 시에만 되돌린다.
    // 제자리 수정이 아니라 새 리스트로 교체해야 state 변경으로 인식돼 리빌드된다.
    _allMusics = _replaceMusic(
      _allMusics,
      musicId,
      original.copyWith(isLiked: willLike, likeCount: nextCount),
    );
    emit(state.copyWith(musics: _applyFilter(_allMusics, state.query), likeResult: null,));

    try {
      if (willLike) {
        await _repository.likeMusic(musicId);
      } else {
        await _repository.unlikeMusic(musicId);
      }
    } catch (e, s) {
      Logger.e('기상음악 좋아요 토글 실패', tag: 'MUSIC', error: e, stackTrace: s);
      // 롤백 — 원래 값으로 복구한다(목록이 재조회로 교체되었으면 무시).
      final currentIndex = _allMusics.indexWhere((m) => m.id == musicId);
      if (currentIndex != -1 && _allMusics[currentIndex].isLiked == willLike) {
        _allMusics = _replaceMusic(_allMusics, musicId, original);
      }

      emit(
        state.copyWith(
          musics: _applyFilter(_allMusics, state.query),
          likeResult: MusicApplyResult(success: false, message: _messageOf(e)),
        ),
      );
    }
  }

  // ── 신청 취소 ──────────────────────────────────────────────

  Future<void> _onCancelRequested(
    Emitter<MusicState> emit,
    int musicId,
  ) async {
    final index = _allMusics.indexWhere((m) => m.id == musicId);
    if (index == -1) return;

    final removed = _allMusics[index];

    // 낙관적 제거 — 항목을 즉시 목록에서 빼고, 실패 시 원래 자리에 되돌린다.
    // 제자리 수정이 아니라 새 리스트로 교체해야 state 변경으로 인식돼 리빌드된다.
    _allMusics = [
      for (final m in _allMusics)
        if (m.id != musicId) m,
    ];
    emit(
      state.copyWith(
        musics: _applyFilter(_allMusics, state.query),
        totalCount: _allMusics.length,
        cancelResult: null,
      ),
    );

    try {
      await _repository.cancelMusic(musicId);
      emit(
        state.copyWith(
          cancelResult: MusicApplyResult(
            success: true,
            message: '기상음악 신청을 취소했어요.',
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('기상음악 신청 취소 실패', tag: 'MUSIC', error: e, stackTrace: s);
      // 롤백 — 이미 제거된 상태라면 원래 위치에 되돌린다(재조회로 교체됐으면 무시).
      if (_allMusics.every((m) => m.id != musicId)) {
        final restored = [..._allMusics];
        restored.insert(index.clamp(0, restored.length), removed);
        _allMusics = restored;
        emit(
          state.copyWith(
            musics: _applyFilter(_allMusics, state.query),
            totalCount: _allMusics.length,
          ),
        );
      }
      emit(
        state.copyWith(
          cancelResult: MusicApplyResult(
            success: false,
            message: e is ApiException ? e.message : '신청 취소를 처리하지 못했어요.',
          ),
        ),
      );
    }
  }

  /// [musicId] 항목만 [replacement] 으로 바꾼 새 리스트를 반환한다(원본 불변).
  List<WakeUpMusic> _replaceMusic(
    List<WakeUpMusic> all,
    int musicId,
    WakeUpMusic replacement,
  ) => [
    for (final m in all) m.id == musicId ? replacement : m,
  ];

  /// [query](노래 제목·신청자 이름)로 [all] 을 필터링한 결과를 반환한다.
  List<WakeUpMusic> _applyFilter(List<WakeUpMusic> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((m) {
      final title = (m.title ?? '').toLowerCase();
      final name = (m.userName ?? '').toLowerCase();
      return title.contains(q) || name.contains(q);
    }).toList();
  }

  // ── 신청 ─────────────────────────────────────────────────

  Future<void> _onApplied(Emitter<MusicState> emit, String musicUrl) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, applyResult: null));
    try {
      await _repository.applyMusic(musicUrl);
      emit(
        state.copyWith(
          isSubmitting: false,
          applyResult: MusicApplyResult(
            success: true,
            message: '기상음악을 신청했어요.',
          ),
        ),
      );
      // 신청 결과가 목록에 즉시 반영되도록 자동 새로고침한다.
      add(const MusicEvent.listRequested(refresh: true));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          applyResult: MusicApplyResult(success: false, message: e.message),
        ),
      );
    } catch (e, s) {
      Logger.e('기상음악 신청 실패', tag: 'MUSIC', error: e, stackTrace: s);
      emit(
        state.copyWith(
          isSubmitting: false,
          applyResult: MusicApplyResult(
            success: false,
            message: '신청을 처리하지 못했어요.',
          ),
        ),
      );
    }
  }

  // ── 실시간(SSE) 구독 ───────────────────────────────────────

  /// SSE 구독을 (재)시작한다. 이벤트는 [MusicEvent.sseReceived] 로 되돌려
  /// 다른 이벤트와 동일하게 순차 처리한다(핸들러를 오래 붙잡지 않는다).
  Future<void> _onSubscriptionStarted() async {
    await _sseSub?.cancel();
    if (_closed) return;
    _reconnectTimer?.cancel();
    _sseSub = _repository.subscribeMusicEvents().listen(
      (event) => add(MusicEvent.sseReceived(event)),
      onError: (Object e, StackTrace s) {
        Logger.e('기상음악 SSE 오류', tag: 'MUSIC', error: e, stackTrace: s);
        _scheduleReconnect();
      },
      onDone: _scheduleReconnect,
      cancelOnError: true,
    );
  }

  /// 연결이 끊기면 잠시 뒤 재연결을 예약한다(close 이후엔 하지 않는다).
  void _scheduleReconnect() {
    if (_closed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_closed) return;
      add(const MusicEvent.subscriptionStarted());
    });
  }

  /// SSE 이벤트를 전체 목록([_allMusics])에 반영하고 필터를 재적용한다.
  void _onSseReceived(Emitter<MusicState> emit, MusicSseEvent event) {
    event.when(
      // 구독 직후 오늘 전체 목록 — 신선한 조회처럼 목록을 교체한다.
      listInitialized: (musics) {
        _allMusics = musics;
        emit(
          state.copyWith(
            listStatus: MusicListStatus.loaded,
            musics: _applyFilter(_allMusics, state.query),
            totalCount: _allMusics.length,
            listError: null,
          ),
        );
      },
      // 신청 1건 — 이미 있으면 갱신, 없으면 추가(타 사용자 신청도 실시간 반영).
      applied: (music) {
        final exists = _allMusics.any((m) => m.id == music.id);
        _allMusics = exists
            ? _replaceMusic(_allMusics, music.id, music)
            : [..._allMusics, music];
        emit(
          state.copyWith(
            musics: _applyFilter(_allMusics, state.query),
            totalCount: _allMusics.length,
          ),
        );
      },
      // 취소 1건 — 목록에서 제거(이미 없으면 무시).
      cancelled: (musicId) {
        if (_allMusics.every((m) => m.id != musicId)) return;
        _allMusics = [
          for (final m in _allMusics)
            if (m.id != musicId) m,
        ];
        emit(
          state.copyWith(
            musics: _applyFilter(_allMusics, state.query),
            totalCount: _allMusics.length,
          ),
        );
      },
      // 좋아요 수 변경 — 총계만 서버 값으로 갱신(개인별 isLiked 는 유지).
      likeUpdated: (musicId, likeCount) {
        final index = _allMusics.indexWhere((m) => m.id == musicId);
        if (index == -1) return;
        _allMusics = _replaceMusic(
          _allMusics,
          musicId,
          _allMusics[index].copyWith(likeCount: likeCount),
        );
        emit(state.copyWith(musics: _applyFilter(_allMusics, state.query)));
      },
    );
  }

  @override
  Future<void> close() {
    _closed = true;
    _reconnectTimer?.cancel();
    _sseSub?.cancel();
    return super.close();
  }

  String _messageOf(Object e) {
    if (e is ApiException) return e.message;
    final raw = e.toString();
    final stripped = raw.startsWith('Exception: ')
        ? raw.substring('Exception: '.length)
        : raw;
    if (e is! Exception || stripped.isEmpty) return '목록을 불러오지 못했어요.';
    return stripped;
  }
}
