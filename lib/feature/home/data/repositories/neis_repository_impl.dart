import 'package:dio/dio.dart';
import 'package:flooding_v2/core/network/api_exception.dart';
import 'package:flooding_v2/core/network/auth_interceptor.dart';
import 'package:flooding_v2/feature/auth/data/datasources/token_storage.dart';
import 'package:flooding_v2/feature/auth/data/flooding_authed_client.dart';
import 'package:flooding_v2/feature/home/data/datasources/neis_api.dart';
import 'package:flooding_v2/feature/home/data/models/timetable_data.dart';
import 'package:flooding_v2/feature/home/domain/repositories/neis_repository.dart';

/// [NeisRepository] 의 Flooding 백엔드 구현.
///
/// API 호출과 에러 정규화만 담당한다 — "다음 교시" 필터링 같은 도메인 로직은
/// [GetNextPeriodUseCase] 쪽에서 처리한다.
class NeisRepositoryImpl implements NeisRepository {
  NeisRepositoryImpl(this._api);

  factory NeisRepositoryImpl.create({
    Dio? dio,
    SessionInvalidator? onSessionExpired,
    TokenStorage? tokenStorage,
  }) {
    final client = FloodingAuthedClient.create(
      dio: dio,
      onSessionExpired: onSessionExpired,
      tokenStorage: tokenStorage,
    );
    final api = NeisApi(client);
    return NeisRepositoryImpl(api);
  }

  final NeisApi _api;

  // GSM(광주소프트웨어마이스터고등학교) 고정 NEIS 식별 코드.
  static const String _officeCode = 'F10';
  static const String _schoolCode = '7380292';

  @override
  Future<TimetableData> fetchTimetable({
    required int grade,
    required int classNumber,
    required DateTime date,
  }) async {
    try {
      final response = await _api.getTimeTables(
        officeCode: _officeCode,
        schoolCode: _schoolCode,
        grade: grade,
        classNumber: classNumber,
        date: _formatDate(date),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.message('시간표를 불러오지 못했어요.');
      }
      return data;
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  String _formatDate(DateTime date) {
    String pad2(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${pad2(date.month)}-${pad2(date.day)}';
  }
}
