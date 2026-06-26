import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/massage_list_response.dart';

part 'massage_api.g.dart';

/// 안마의자 API 경로 — 공통 prefix([ApiEndpoints.dormitory])를 합성한다.
class _Endpoints {
  _Endpoints._();

  static const String massages = '${ApiEndpoints.dormitory}/massages';
}

/// Flooding 백엔드 안마의자(`/dormitory/massages`) API.
///
/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class MassageApi {
  factory MassageApi(Dio dio, {String? baseUrl}) = _MassageApi;

  /// 안마의자 신청자 목록 조회.
  @GET(_Endpoints.massages)
  Future<MassageListResponse> getApplicants();

  /// 안마의자 신청.
  @POST(_Endpoints.massages)
  Future<void> requestMassage();

  /// 안마의자 신청 취소.
  @DELETE(_Endpoints.massages)
  Future<void> cancelMassage();
}
