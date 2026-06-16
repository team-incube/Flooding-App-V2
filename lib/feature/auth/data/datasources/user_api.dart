import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/me.dart';

part 'user_api.g.dart';

/// 사용자 API 경로 — 공통 prefix([ApiEndpoints.users])를 합성한다.
class _Endpoints {
  _Endpoints._();

  static const String me = '${ApiEndpoints.users}/me';
}

/// Flooding 백엔드 사용자(`/users`) API.
///
/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String? baseUrl}) = _UserApi;

  /// 내 정보 조회 — 세션 유효성 검사에 사용한다(401 시 미인증).
  @GET(_Endpoints.me)
  Future<MeResponse> getMe();
}
