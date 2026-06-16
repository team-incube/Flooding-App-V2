import 'package:dio/dio.dart';

import '../../../../core/network/flooding_api_client.dart';
import '../../../auth/data/datasources/token_storage.dart';
import '../../domain/study_repository.dart';
import '../../domain/study_request_policy.dart';
import '../datasources/study_api.dart';
import '../models/study_applicant.dart';

/// [StudyRepository] 의 Flooding 백엔드 구현.
///
/// - 신청 가능 시간([StudyRequestPolicy]) 을 호출 전에 적용한다.
/// - 백엔드 [DioException] 을 [StudyException] 으로 변환한다.
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
      return response.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> requestStudy() async {
    final status = _policy.statusAt(_clock());
    if (status != StudyWindowStatus.open) {
      throw StudyException(
        StudyFailureReason.outOfTime,
        status == StudyWindowStatus.beforeOpen
            ? '자습 신청은 20:00부터 가능해요.'
            : '자습 신청 시간(20:00 ~ 21:00)이 지났어요.',
      );
    }
    try {
      await _api.requestStudy();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> cancelStudy() async {
    try {
      await _api.cancelStudy();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// [DioException] 의 상태 코드를 도메인 실패 사유로 변환한다.
  StudyException _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = _serverMessage(e);
    switch (statusCode) {
      case 400:
        return StudyException(
          StudyFailureReason.outOfTime,
          message ?? '자습 신청 시간이 아니에요.',
        );
      case 401:
        return StudyException(StudyFailureReason.unauthorized, message);
      case 403:
        return StudyException(
          StudyFailureReason.banned,
          message ?? '자습이 금지된 상태예요.',
        );
      case 404:
        return StudyException(
          StudyFailureReason.notFound,
          message ?? '자습 신청 내역이 없어요.',
        );
      case 409:
        return StudyException(
          StudyFailureReason.conflict,
          message ?? '이미 신청했거나 신청할 수 없는 상태예요.',
        );
      default:
        if (_isNetworkError(e)) {
          return const StudyException(
            StudyFailureReason.network,
            '네트워크 연결을 확인해 주세요.',
          );
        }
        return StudyException(StudyFailureReason.unknown, message);
    }
  }

  String? _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }

  bool _isNetworkError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }
}
