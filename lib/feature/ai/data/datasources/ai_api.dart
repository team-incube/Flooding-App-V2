import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/chat_request.dart';
import '../models/chat_response.dart';
import '../models/recommend_song_response.dart';

part 'ai_api.g.dart';

/// AI 챗봇 API 경로 — 공통 prefix([ApiEndpoints.ai])를 합성한다.
const String _chat = '${ApiEndpoints.ai}/chat';

/// AI 음악 추천 API 경로.
const String _song = '${ApiEndpoints.ai}/song';

/// Flooding 백엔드 AI(`/ai`) API.
///
/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class AiApi {
  factory AiApi(Dio dio, {String? baseUrl}) = _AiApi;

  /// 사용자 입력을 AI 챗봇 서버로 전달하고 응답을 반환한다.
  @POST(_chat)
  Future<ChatResponse> sendMessage(@Body() ChatRequest request);

  /// 로그인 사용자의 최근 기상송 신청 내역을 기반으로 AI 추천 유튜브 링크를
  /// 받는다. 요청 본문은 없다(서버가 사용자 내역을 조회한다).
  @POST(_song)
  Future<RecommendSongResponse> recommendSong();
}
