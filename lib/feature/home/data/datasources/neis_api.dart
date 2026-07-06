import 'package:dio/dio.dart';
import 'package:flooding_v2/core/network/api_endpoints.dart';
import 'package:flooding_v2/feature/home/data/models/timetable_list_response.dart';
import 'package:retrofit/retrofit.dart';

part 'neis_api.g.dart';

class _Endpoints {
  const _Endpoints._();

  static const String timeTables = '${ApiEndpoints.neis}/timetables';
}

@RestApi()
abstract class NeisApi {
  factory NeisApi(Dio dio, {String? baseUrl}) = _NeisApi;

  @GET(_Endpoints.timeTables)
  Future<TimetableListResponse> getTimeTables({
    @Query('officeCode') required String officeCode,
    @Query('schoolCode') required String schoolCode,
    @Query('grade') required int grade,
    @Query('classNumber') required int classNumber,
    @Query('date') required String date,
  });
}
