import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/create_homebase_request.dart';
import '../models/homebase_reservation_list_response.dart';

part 'school_api.g.dart';

/// Flooding 백엔드 홈베이스(`/homebase`) API.
///
/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class SchoolApi {
  factory SchoolApi(Dio dio, {String? baseUrl}) = _SchoolApi;

  /// 날짜별 홈베이스 예약 목록 조회. [date] 는 `yyyy-MM-dd`.
  @GET(ApiEndpoints.homebase)
  Future<HomebaseReservationListResponse> getReservations(
    @Query('date') String date,
  );

  /// [homebaseId] 좌석에 홈베이스 예약 생성.
  @POST('${ApiEndpoints.homebase}/{homebaseId}')
  Future<void> createReservation(
    @Path('homebaseId') int homebaseId,
    @Body() CreateHomebaseRequest request,
  );

  /// 홈베이스 예약 삭제.
  @DELETE('${ApiEndpoints.homebase}/{reservationId}')
  Future<void> deleteReservation(@Path('reservationId') int reservationId);
}
