import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/oauth_token.dart';
import '../models/refresh_request.dart';
import '../models/token_request.dart';

part 'datagsm_auth_api.g.dart';

/// DataGSM 인증 서버 경로 — Flooding 백엔드와 별개 호스트라 ApiEndpoints 를 쓰지 않는다.
const String _token = '/v1/oauth/token';

/// DataGSM 인증 서버(`oauth.authorization.datagsm.kr`) — token 교환/갱신.
@RestApi()
abstract class DatagsmAuthApi {
  factory DatagsmAuthApi(Dio dio, {String? baseUrl}) = _DatagsmAuthApi;

  @POST(_token)
  Future<OAuthToken> exchangeToken(@Body() TokenRequest request);

  @POST(_token)
  Future<OAuthToken> refreshToken(@Body() RefreshRequest request);
}
