import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import '../../../../core/network/flooding_sse_client.dart';
import '../../../../core/network/sse_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/token_storage.dart';
import '../../../auth/data/flooding_authed_client.dart';
import '../../domain/enum/music_sort.dart';
import '../../domain/models/music_sse_event.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/music_api.dart';
import '../models/apply_wake_up_music_request.dart';
import '../models/wake_up_music.dart';

/// [MusicRepository] 의 Flooding 백엔드 구현.
///
/// 백엔드 [DioException] 은 [DioExceptionX.toApiException] 으로 풀어 던진다.
///
/// 인증: 저장된 access token 을 Bearer 로 주입하고, 401 시 `/auth/reissue` 로
/// 토큰을 갱신해 1회 재시도한다. 갱신 실패 시 [onSessionExpired] 로 세션을
/// 종료해 로그인 화면으로 되돌린다.
class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl(this._api, this._dio);

  /// 실제 네트워크 클라이언트를 구성하는 팩토리.
  ///
  /// [onSessionExpired] 를 주면 토큰 갱신 실패 시 호출돼 로그인 화면으로
  /// 되돌릴 수 있다(보통 `AuthController.expireSession`).
  factory MusicRepositoryImpl.create({
    Dio? dio,
    TokenStorage? tokenStorage,
    SessionInvalidator? onSessionExpired,
  }) {
    final storage = tokenStorage ?? TokenStorage();
    final client = FloodingAuthedClient.create(
      tokenStorage: storage,
      onSessionExpired: onSessionExpired,
      dio: dio,
    );
    // SSE 는 수신 타임아웃 없는 전용 클라이언트로 분리한다(REST 와 별개).
    final sseClient = FloodingSseClient.create(
      tokenStorage: storage,
      onSessionExpired: onSessionExpired,
    );
    return MusicRepositoryImpl(MusicApi(client), sseClient);
  }

  final MusicApi _api;

  /// SSE 스트리밍 구독 전용 인증 dio(REST 클라이언트와 분리).
  final Dio _dio;

  @override
  Future<List<WakeUpMusic>> fetchMusicList({
    DateTime? date,
    MusicSort sort = MusicSort.time,
  }) async {
    try {
      final response = await _api.getMusicList(
        date: date == null ? null : _formatDate(date),
        sort: sort.query,
      );
      return response.data;
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Stream<MusicSseEvent> subscribeMusicEvents() async* {
    final stream = connectSse(
      _dio,
      '${ApiEndpoints.dormitory}/music/subscribe',
    );
    await for (final message in stream) {
      final event = _toSseEvent(message);
      if (event != null) yield event;
    }
  }

  /// 원시 [SseMessage] 를 도메인 [MusicSseEvent] 로 변환한다.
  ///
  /// `connect`(연결 확인) 등 처리 대상이 아닌 이벤트나 파싱 실패는 null 을
  /// 반환해 스트림을 끊지 않고 건너뛴다.
  MusicSseEvent? _toSseEvent(SseMessage message) {
    try {
      switch (message.event) {
        case 'init':
          final list = (jsonDecode(message.data) as List)
              .cast<Map<String, dynamic>>()
              .map(WakeUpMusic.fromJson)
              .toList();
          return MusicListInitialized(list);
        case 'music-applied':
          final json = jsonDecode(message.data) as Map<String, dynamic>;
          return MusicApplied(WakeUpMusic.fromJson(json));
        case 'music-cancelled':
          final json = jsonDecode(message.data) as Map<String, dynamic>;
          return MusicCancelled((json['musicId'] as num).toInt());
        case 'music-like-updated':
          final json = jsonDecode(message.data) as Map<String, dynamic>;
          return MusicLikeUpdated(
            musicId: (json['musicId'] as num).toInt(),
            likeCount: (json['likeCount'] as num).toInt(),
          );
        default:
          return null;
      }
    } catch (e, s) {
      Logger.e(
        '기상음악 SSE 이벤트 파싱 실패: ${message.event}',
        tag: 'MUSIC',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  @override
  Future<WakeUpMusic> applyMusic(String musicUrl) async {
    try {
      final response = await _api.applyMusic(
        ApplyWakeUpMusicRequest(musicUrl: musicUrl),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.message('신청 응답이 비어 있어요.');
      }
      return data;
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> cancelMusic(int musicId) async {
    try {
      await _api.cancelMusic(musicId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> likeMusic(int musicId) async {
    try {
      await _api.likeMusic(musicId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> unlikeMusic(int musicId) async {
    try {
      await _api.unlikeMusic(musicId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  /// `yyyy-MM-dd` 로 포맷한다(쿼리 파라미터용).
  static String _formatDate(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
