import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import '../../../auth/data/datasources/token_storage.dart';
import '../../../auth/data/flooding_authed_client.dart';
import '../../domain/repositories/massage_repository.dart';
import '../../domain/repositories/massage_request_policy.dart';
import '../datasources/massage_api.dart';
import '../models/massage_applicant.dart';

/// [MassageRepository] 의 Flooding 백엔드 구현.
///
/// - 신청 가능 시간([MassageRequestPolicy]) 을 호출 전에 적용한다.
/// - 백엔드 [DioException] 은 [ErrorInterceptor] 가 [ApiException] 으로
///   정규화하므로, 여기서는 [DioExceptionX.toApiException] 으로 풀어 던지기만 한다.
///
/// 인증: 저장된 access token 을 Bearer 로 주입하고, 401 시 `/auth/reissue` 로
/// 토큰을 갱신해 1회 재시도한다. 갱신 실패 시 [onSessionExpired] 로 세션을
/// 종료해 로그인 화면으로 되돌린다.
class MassageRepositoryImpl implements MassageRepository {
  MassageRepositoryImpl(
    this._api, {
    MassageRequestPolicy policy = const MassageRequestPolicy(),
    DateTime Function() clock = DateTime.now,
  }) : _policy = policy,
       _clock = clock;

  /// 실제 네트워크 클라이언트를 구성하는 팩토리.
  ///
  /// [onSessionExpired] 를 주면 토큰 갱신 실패 시 호출돼 로그인 화면으로
  /// 되돌릴 수 있다(보통 `AuthController.expireSession`).
  factory MassageRepositoryImpl.create({
    Dio? dio,
    TokenStorage? tokenStorage,
    SessionInvalidator? onSessionExpired,
    MassageRequestPolicy policy = const MassageRequestPolicy(),
    DateTime Function() clock = DateTime.now,
  }) {
    final storage = tokenStorage ?? TokenStorage();
    final client = FloodingAuthedClient.create(
      tokenStorage: storage,
      onSessionExpired: onSessionExpired,
      dio: dio,
    );
    final api = MassageApi(client);
    return MassageRepositoryImpl(api, policy: policy, clock: clock);
  }

  final MassageApi _api;
  final MassageRequestPolicy _policy;
  final DateTime Function() _clock;

  @override
  Future<List<MassageApplicant>> fetchApplicants() async {
    try {
      final response = await _api.getApplicants();
      return response.data?.applicants ?? const [];
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> requestMassage() async {
    final status = _policy.statusAt(_clock());
    if (status != MassageWindowStatus.open) {
      throw ApiException.message(
        status == MassageWindowStatus.beforeOpen
            ? '안마의자 신청은 20:20부터 가능해요.'
            : '안마의자 신청 시간(20:20 ~ 21:00)이 지났어요.',
      );
    }
    try {
      await _api.requestMassage();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  @override
  Future<void> cancelMassage() async {
    try {
      await _api.cancelMassage();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }
}
