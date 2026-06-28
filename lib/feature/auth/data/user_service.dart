import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_interceptor.dart' show SessionInvalidator;
import 'datasources/token_storage.dart';
import 'datasources/user_api.dart';
import 'flooding_authed_client.dart';
import 'models/me.dart';

/// 세션 유효성 검사 결과.
enum SessionCheck {
  /// `/users/me` 200 — 유효한 세션.
  valid,

  /// `/users/me` 401 — 토큰 만료/무효, 재로그인 필요.
  unauthorized,

  /// 연결 실패·타임아웃 — 서버에 닿지 못함(오프라인 가능).
  networkError,

  /// 그 외(서버 5xx 등) 판단 불가.
  unknown,
}

/// 세션 검사 결과와, 그 과정에서 받은 내 정보를 함께 담는다.
///
/// 검사용 `/users/me` 호출이 이미 본문을 받아오므로, [me] 를 재사용하면
/// 진입 직후 같은 엔드포인트를 다시 부르지 않아도 된다([SessionCheck.valid] 일 때만 채워진다).
typedef SessionResult = ({SessionCheck check, Me? me});

/// 앱 진입 시 세션 유효성을 검사하는 계약.
abstract interface class SessionValidator {
  Future<SessionResult> validateSession({Duration timeout});
}

/// Flooding 백엔드 사용자 정보 조회 서비스.
class UserService implements SessionValidator {
  UserService({
    Dio? dio,
    TokenStorage? tokenStorage,
    SessionInvalidator? onSessionExpired,
  }) : _dio = dio,
       _storage = tokenStorage ?? TokenStorage(),
       _onSessionExpired = onSessionExpired;

  final Dio? _dio;
  final TokenStorage _storage;
  final SessionInvalidator? _onSessionExpired;

  // 첫 사용 시점에 클라이언트를 만든다 — 생성 시 Env 읽기를 피한다.
  late final UserApi _api = UserApi(
    FloodingAuthedClient.create(
      tokenStorage: _storage,
      onSessionExpired: _onSessionExpired,
      dio: _dio,
    ),
  );

  /// 내 정보를 조회한다. 실패 시 [DioException] 등을 그대로 던진다.
  Future<Me?> fetchMe() async {
    final response = await _api.getMe();
    return response.data;
  }

  /// 앱 진입 시 세션 유효성을 검사한다 — `/users/me` 의 401 여부로 판정한다.
  ///
  /// 시작 화면이 오래 막히지 않도록 [timeout] 을 둔다(기본 5초).
  @override
  Future<SessionResult> validateSession({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      // 검사용 호출이 받아온 본문을 함께 돌려주어, 진입 직후 같은 `/users/me` 를
      // 다시 부르지 않고 내 정보를 재사용할 수 있게 한다.
      final response = await _api.getMe().timeout(timeout);
      return (check: SessionCheck.valid, me: response.data);
    } on TimeoutException {
      // .timeout() 이 Dio 자체 타임아웃보다 먼저 끊은 경우 — 네트워크 지연.
      return (check: SessionCheck.networkError, me: null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return (check: SessionCheck.unauthorized, me: null);
      }
      return (
        check: e.toApiException().isNetwork
            ? SessionCheck.networkError
            : SessionCheck.unknown,
        me: null,
      );
    } catch (_) {
      return (check: SessionCheck.unknown, me: null);
    }
  }
}
