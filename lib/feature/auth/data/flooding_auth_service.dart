import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import 'datagsm_auth_service.dart' show AuthException;
import 'datasources/flooding_auth_api.dart';
import 'models/reissue_request.dart';
import 'models/signin_request.dart';
import 'models/signin_response.dart';

/// Flooding 백엔드 로그인(`/auth/signin`) 서비스.
///
/// DataGSM OAuth 로그인으로 받은 인가 코드를 백엔드로 보내,
/// Flooding access/refresh 토큰을 발급받는다(인증 브릿지).
class FloodingAuthService {
  FloodingAuthService({FloodingAuthApi? api}) : _injectedApi = api;

  final FloodingAuthApi? _injectedApi;

  // 기본 클라이언트는 첫 사용(로그인) 시점에 만든다 — 생성 시 Env 읽기를 피한다.
  late final FloodingAuthApi _api = _injectedApi ?? FloodingAuthApi(_defaultClient());

  static Dio _defaultClient() {
    final dio = DioClient.create();
    dio.options.baseUrl = Env.apiBaseUrl;
    return dio;
  }

  /// 인가 코드로 로그인해 Flooding 토큰을 발급받는다.
  ///
  /// 학생이 아닌 사용자(403)는 [AuthException] 으로 변환한다.
  Future<SigninData> signin({
    required String authCode,
    required String redirectUri,
  }) async {
    try {
      final response = await _api.signin(
        SigninRequest(authCode: authCode, redirectUri: redirectUri),
      );
      final data = response.data;
      if (data == null) {
        throw const AuthException('로그인 응답이 비어 있습니다.');
      }
      return data;
    } on DioException catch (e) {
      Logger.e(
        'signin 실패: ${e.response?.statusCode} ${e.response?.data}',
        tag: 'AUTH',
        error: e,
      );
      if (e.response?.statusCode == 403) {
        throw const AuthException('학생만 로그인할 수 있어요.');
      }
      throw const AuthException('로그인에 실패했습니다.');
    }
  }

  /// refresh token 으로 토큰을 재발급한다.
  ///
  /// refresh token 이 유효하지 않으면(401) [AuthException] 으로 변환한다.
  Future<SigninData> reissue({required String refreshToken}) async {
    try {
      final response = await _api.reissue(
        ReissueRequest(refreshToken: refreshToken),
      );
      final data = response.data;
      if (data == null) {
        throw const AuthException('토큰 재발급 응답이 비어 있습니다.');
      }
      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('세션이 만료되었습니다. 다시 로그인해 주세요.');
      }
      throw const AuthException('토큰 재발급에 실패했습니다.');
    }
  }
}
