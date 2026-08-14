import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/create_homebase_request.dart';
import '../models/homebase_reservation_list_response.dart';

part 'school_api.g.dart';

/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class SchoolApi {
  factory SchoolApi(Dio dio, {String? baseUrl}) = _SchoolApi;

  /// [date] 는 `yyyy-MM-dd`.
  @GET(ApiEndpoints.homebase)
  Future<HomebaseReservationListResponse> getReservations(
    @Query('date') String date,
  );

  @POST('${ApiEndpoints.homebase}/{homebaseId}')
  Future<void> createReservation(
    @Path('homebaseId') int homebaseId,
    @Body() CreateHomebaseRequest request,
  );

  @DELETE('${ApiEndpoints.homebase}/{reservationId}')
  Future<void> deleteReservation(@Path('reservationId') int reservationId);
}
