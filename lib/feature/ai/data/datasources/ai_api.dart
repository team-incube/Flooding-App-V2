import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/chat_request.dart';
import '../models/chat_response.dart';

part 'ai_api.g.dart';

/// AI 챗봇 API 경로 — 공통 prefix([ApiEndpoints.ai])를 합성한다.
class _Endpoints {
  _Endpoints._();

  static const String chat = '${ApiEndpoints.ai}/chat';
}

/// Flooding 백엔드 AI 챗봇(`/ai/chat`) API.
///
/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class AiApi {
  factory AiApi(Dio dio, {String? baseUrl}) = _AiApi;

  /// 사용자 입력을 AI 챗봇 서버로 전달하고 응답을 반환한다.
  @POST(_Endpoints.chat)
  Future<ChatResponse> sendMessage(@Body() ChatRequest request);
}
