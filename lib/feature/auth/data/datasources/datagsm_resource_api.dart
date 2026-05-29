import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/datagsm_user.dart';

part 'datagsm_resource_api.g.dart';

/// DataGSM 리소스 서버(`oauth.resource.datagsm.kr`) — 사용자 정보 조회.
///
/// `Authorization` 헤더는 [AuthInterceptor] 가 주입하므로 별도 인자를 받지 않는다.
@RestApi()
abstract class DatagsmResourceApi {
  factory DatagsmResourceApi(Dio dio, {String? baseUrl}) = _DatagsmResourceApi;

  @GET('/userinfo')
  Future<DatagsmUser> getUserInfo();
}
