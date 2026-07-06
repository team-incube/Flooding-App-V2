import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import '../../../auth/data/datasources/token_storage.dart';
import '../../../auth/data/flooding_authed_client.dart';
import '../../domain/repositories/study_repository.dart';
import '../../domain/repositories/study_request_policy.dart';
import '../datasources/study_api.dart';
import '../models/study_applicant.dart';

/// [StudyRepository] 의 Flooding 백엔드 구현.
///
/// - 신청 가능 시간([StudyRequestPolicy]) 을 호출 전에 적용한다.
/// - 백엔드 [DioException] 은 [ErrorInterceptor] 가 [ApiException] 으로
///   정규화하므로, 여기서는 [DioExceptionX.toApiException] 으로 풀어 던지기만 한다.
///
/// 인증: 저장된 access token 을 Bearer 로 주입하고, 401 시 `/auth/reissue` 로
/// 토큰을 갱신해 1회 재시도한다. 갱신 실패 시 [onSessionExpired] 로 세션을
/// 종료해 로그인 화면으로 되돌린다.
class StudyRepositoryImpl implements StudyRepository {
  StudyRepositoryImpl(
    this._api, {
    StudyRequestPolicy policy = const StudyRequestPolicy(),
    DateTime Function() clock = DateTime.now,
  }) : _policy = policy,
       _clock = clock;

  /// 실제 네트워크 클라이언트를 구성하는 팩토리.
  ///
  /// [onSessionExpired] 를 주면 토큰 갱신 실패 시 호출돼 로그인 화면으로
  /// 되돌릴 수 있다(보통 `AuthController.expireSession`).
  factory StudyRepositoryImpl.create({
    Dio? dio,
    TokenStorage? tokenStorage,
    SessionInvalidator? onSessionExpired,
    StudyRequestPolicy policy = const StudyRequestPolicy(),
    DateTime Function() clock = DateTime.now,
  }) {
    final storage = tokenStorage ?? TokenStorage();
    final client = FloodingAuthedClient.create(
      tokenStorage: storage,
      onSessionExpired: onSessionExpired,
      dio: dio,
    );
    final api = StudyApi(client);
    return StudyRepositoryImpl(api, policy: policy, clock: clock);
  }

  final StudyApi _api;
  final StudyRequestPolicy _policy;
  final DateTime Function() _clock;

  @override
  Future<List<StudyApplicant>> fetchApplicants() async {
    try {
      final response = await _api.getApplicants();
      return response.data?.applicants ?? const [];
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> requestStudy() async {
    final status = _policy.statusAt(_clock());
    if (status != StudyWindowStatus.open) {
      throw ApiException.message(
        status == StudyWindowStatus.beforeOpen
            ? '자습 신청은 20:00부터 가능해요.'
            : '자습 신청 시간(20:00 ~ 21:00)이 지났어요.',
      );
    }
    try {
      await _api.requestStudy();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> cancelStudy() async {
    try {
      await _api.cancelStudy();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> checkIn(int userId) async {
    try {
      await _api.checkIn(userId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> checkOut(int userId) async {
    try {
      await _api.checkOut(userId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }
}
