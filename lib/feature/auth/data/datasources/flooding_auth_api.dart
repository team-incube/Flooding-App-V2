import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/reissue_request.dart';
import '../models/signin_request.dart';
import '../models/signin_response.dart';

part 'flooding_auth_api.g.dart';

/// 인증 API 경로 — 공통 prefix([ApiEndpoints.auth])를 합성한다.
class _Endpoints {
  _Endpoints._();

  static const String signin = '${ApiEndpoints.auth}/signin';
  static const String reissue = '${ApiEndpoints.auth}/reissue';
}

/// Flooding 백엔드 인증(`/auth`) API.
///
/// 로그인 엔드포인트라 Bearer 인증이 필요 없다.
@RestApi()
abstract class FloodingAuthApi {
  factory FloodingAuthApi(Dio dio, {String? baseUrl}) = _FloodingAuthApi;

  /// OAuth 인가 코드로 로그인 — Flooding access/refresh 토큰을 발급한다.
  @POST(_Endpoints.signin)
  Future<SigninResponse> signin(@Body() SigninRequest request);

  /// refresh token 으로 access/refresh 토큰을 재발급한다(기존 refresh 는 무효화).
  @POST(_Endpoints.reissue)
  Future<SigninResponse> reissue(@Body() ReissueRequest request);
}
