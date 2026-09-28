import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/study_list_response.dart';

part 'study_api.g.dart';

/// 자습 API 경로 — 공통 prefix([ApiEndpoints.dormitory])를 합성한다.
const String _studies = '${ApiEndpoints.dormitory}/studies';
const String _attendance = '$_studies/attendance';

/// Flooding 백엔드 자습(`/dormitory/studies`) API.
///
/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class StudyApi {
  factory StudyApi(Dio dio, {String? baseUrl}) = _StudyApi;

  /// 자습 신청자 목록 조회.
  @GET(_studies)
  Future<StudyListResponse> getApplicants();

  /// 자습 신청.
  @POST(_studies)
  Future<void> requestStudy();

  /// 자습 신청 취소.
  @DELETE(_studies)
  Future<void> cancelStudy();

  /// 자습 체크인(출석) 처리.
  ///
  /// [userId] 는 체크인할 학생의 ID. 404: 학생 또는 신청 내역 없음,
  /// 409: 이미 체크인 완료.
  @POST('$_attendance/{userId}')
  Future<void> checkIn(@Path('userId') int userId);

  /// 자습 체크인 취소(출석 해제).
  ///
  /// [userId] 는 대상 학생의 ID.
  @DELETE('$_attendance/{userId}')
  Future<void> checkOut(@Path('userId') int userId);
}
