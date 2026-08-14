import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import '../../../auth/data/datasources/token_storage.dart';
import '../../../auth/data/flooding_authed_client.dart';
import '../../domain/repositories/school_repository.dart';
import '../datasources/school_api.dart';
import '../models/create_homebase_request.dart';
import '../models/homebase_member.dart';
import '../models/homebase_reservation.dart';

/// [SchoolRepository] 의 Flooding 백엔드 구현.
///
/// 백엔드 [DioException] 은 [DioExceptionX.toApiException] 으로 풀어 던진다.
///
/// 인증: 저장된 access token 을 Bearer 로 주입하고, 401 시 `/auth/reissue` 로
/// 토큰을 갱신해 1회 재시도한다. 갱신 실패 시 [onSessionExpired] 로 세션을
/// 종료해 로그인 화면으로 되돌린다.
class SchoolRepositoryImpl implements SchoolRepository {
  SchoolRepositoryImpl(this._api);

  /// 실제 네트워크 클라이언트를 구성하는 팩토리.
  factory SchoolRepositoryImpl.create({
    Dio? dio,
    TokenStorage? tokenStorage,
    SessionInvalidator? onSessionExpired,
  }) {
    final storage = tokenStorage ?? TokenStorage();
    final client = FloodingAuthedClient.create(
      tokenStorage: storage,
      onSessionExpired: onSessionExpired,
      dio: dio,
    );
    return SchoolRepositoryImpl(SchoolApi(client));
  }

  final SchoolApi _api;

  @override
  Future<List<HomebaseReservation>> fetchReservations(DateTime date) async {
    try {
      final response = await _api.getReservations(_formatDate(date));
      return response.data;
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> createReservation({
    required int homebaseId,
    required DateTime date,
    required int startPeriod,
    required int endPeriod,
    required String reason,
    required List<HomebaseMember> members,
  }) async {
    try {
      await _api.createReservation(
        homebaseId,
        CreateHomebaseRequest(
          reservationDate: _formatDate(date),
          startPeriod: startPeriod,
          endPeriod: endPeriod,
          reason: reason,
          members: members,
        ),
      );
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> deleteReservation(int reservationId) async {
    try {
      await _api.deleteReservation(reservationId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  /// `yyyy-MM-dd` 로 포맷한다(쿼리·요청 본문 공통).
  static String _formatDate(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
