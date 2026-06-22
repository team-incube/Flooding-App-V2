import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import '../../../auth/data/datasources/token_storage.dart';
import '../../../auth/data/flooding_authed_client.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_api.dart';
import '../models/chat_request.dart';

/// [AiRepository] 의 Flooding 백엔드 구현.
///
/// 백엔드 [DioException] 은 [ErrorInterceptor] 가 [ApiException] 으로
/// 정규화하므로, 여기서는 [DioExceptionX.toApiException] 으로 풀어 던진다.
/// 단, AI 챗봇 서버 오류(502)는 사용자 친화 메시지로 바꿔 던진다.
///
/// 인증: 저장된 access token 을 Bearer 로 주입하고, 401 시 `/auth/reissue` 로
/// 토큰을 갱신해 1회 재시도한다. 갱신 실패 시 [onSessionExpired] 로 세션을
/// 종료해 로그인 화면으로 되돌린다.
class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._api);

  /// 실제 네트워크 클라이언트를 구성하는 팩토리.
  ///
  /// [onSessionExpired] 를 주면 토큰 갱신 실패 시 호출돼 로그인 화면으로
  /// 되돌릴 수 있다(보통 `AuthController.expireSession`).
  factory AiRepositoryImpl.create({
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
    return AiRepositoryImpl(AiApi(client));
  }

  final AiApi _api;

  @override
  Future<String> sendMessage(String userInput) async {
    try {
      final response = await _api.sendMessage(
        ChatRequest(userInput: userInput),
      );
      final reply = response.data?.response;
      if (reply == null || reply.isEmpty) {
        throw const ApiException.message('AI 응답을 받지 못했어요.');
      }
      return reply;
    } on DioException catch (e) {
      final api = e.toApiException();
      // 502: AI 챗봇 서버 오류 — 일반 fallback 대신 명확한 안내로 바꾼다.
      if (api.statusCode == 502) {
        throw const ApiException.message(
          'AI 챗봇 서버가 응답하지 않아요. 잠시 후 다시 시도해 주세요.',
        );
      }
      throw api;
    }
  }
}
