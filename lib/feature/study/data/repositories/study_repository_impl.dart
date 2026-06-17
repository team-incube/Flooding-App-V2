import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/flooding_api_client.dart';
import '../../../auth/data/datasources/token_storage.dart';
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
/// 인증: 저장된 access token 을 Bearer 로 주입한다.
/// 단, Flooding 백엔드 토큰 발급(인증 브릿지)은 별도 작업이며,
/// 현재는 401 자동 갱신(refresh)을 연결하지 않는다.
class StudyRepositoryImpl implements StudyRepository {
  StudyRepositoryImpl(
    this._api, {
    StudyRequestPolicy policy = const StudyRequestPolicy(),
    DateTime Function() clock = DateTime.now,
  }) : _policy = policy,
       _clock = clock;

  /// 실제 네트워크 클라이언트를 구성하는 팩토리.
  factory StudyRepositoryImpl.create({
    Dio? dio,
    TokenStorage? tokenStorage,
    StudyRequestPolicy policy = const StudyRequestPolicy(),
    DateTime Function() clock = DateTime.now,
  }) {
    final storage = tokenStorage ?? TokenStorage();
    final client = FloodingApiClient.create(
      accessToken: storage.readAccessToken,
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
}
