import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import '../../../auth/data/datasources/token_storage.dart';
import '../../../auth/data/flooding_authed_client.dart';
import '../../domain/enum/music_sort.dart';
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
  MusicRepositoryImpl(this._api);

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
    return MusicRepositoryImpl(MusicApi(client));
  }

  final MusicApi _api;

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
