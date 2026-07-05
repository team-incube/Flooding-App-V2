import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/apply_wake_up_music_request.dart';
import '../models/wake_up_music_list_response.dart';
import '../models/wake_up_music_response.dart';

part 'music_api.g.dart';

/// 기상음악 API 경로 — 공통 prefix([ApiEndpoints.dormitory])를 합성한다.
const String _music = '${ApiEndpoints.dormitory}/music';

/// Flooding 백엔드 기상음악(`/dormitory/music`) API.
///
/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class MusicApi {
  factory MusicApi(Dio dio, {String? baseUrl}) = _MusicApi;

  /// 날짜별 기상음악 신청 목록 조회.
  ///
  /// [date] 는 `yyyy-MM-dd`(미지정 시 서버 기본), [sort] 는 `TIME`/`LIKE`.
  @GET(_music)
  Future<WakeUpMusicListResponse> getMusicList({
    @Query('date') String? date,
    @Query('sort') String? sort,
  });

  /// 기상음악 신청 — 이미 신청한 경우 409.
  @POST(_music)
  Future<WakeUpMusicResponse> applyMusic(
    @Body() ApplyWakeUpMusicRequest request,
  );
}
