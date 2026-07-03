import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/enum/music_sort.dart';
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
      );
    });
  }

  final MusicRepository _repository;

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
      final musics = await _repository.fetchMusicList(
        date: nextDate,
        sort: nextSort,
      );
      emit(
        state.copyWith(listStatus: MusicListStatus.loaded, musics: musics),
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
      emit(
        state.copyWith(
          listStatus: MusicListStatus.error,
          musics: const [],
          listError: _messageOf(e),
        ),
      );
    }
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
