import 'package:appium_flutter_server/appium_flutter_server.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flooding_v2/core/config/env.dart';
import 'package:flooding_v2/feature/auth/data/datasources/token_storage.dart';
import 'package:flooding_v2/feature/auth/data/models/me.dart';
import 'package:flooding_v2/feature/auth/data/models/oauth_token.dart';
import 'package:flooding_v2/feature/auth/data/user_service.dart';
import 'package:flooding_v2/feature/auth/presentation/auth_controller.dart';
import 'package:flooding_v2/main.dart';

/// Appium UI 테스트 진입점.
///
/// 실제 main() 과 동일하게 부팅하되, 토큰 저장소를 인메모리 가짜로 바꿔
/// OAuth 로그인 없이 곧장 home 으로 진입한다. UI/퍼블리싱 검증이 목적이므로
/// 실 API 호출이 필요한 화면은 각 테스트에서 별도 처리한다.
void main() {
  initializeTest(
    callback: (WidgetTester tester) async {
      await Env.load();

      final tokenStorage = _FakeTokenStorage();
      final userService = _FakeUserService();

      final authController = AuthController(
        sessionValidator: _FakeSessionValidator(),
        tokenStorage: tokenStorage,
      );
      await authController.bootstrap();

      await tester.pumpWidget(
        FloodingApp(authController: authController),
      );
    },
  );
}

/// 항상 더미 토큰을 보유한 것처럼 동작하는 테스트용 저장소.
class _FakeTokenStorage extends TokenStorage {
  String? _access = 'appium-test-access-token';
  String? _refresh = 'appium-test-refresh-token';

  @override
  Future<void> save(OAuthToken token) async {
    _access = token.accessToken;
    _refresh = token.refreshToken;
  }

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

/// 항상 세션이 유효한 것처럼 동작하는 테스트용 세션 검증기.
class _FakeSessionValidator implements SessionValidator {
  @override
  Future<SessionCheck> validateSession({
    Duration timeout = Duration.zero,
  }) async => SessionCheck.valid;
}

/// 고정된 테스트 유저를 반환하는 테스트용 UserService.
class _FakeUserService extends UserService {
  _FakeUserService() : super();

  @override
  Future<Me?> fetchMe() async => const Me(
    id: 1,
    name: '테스트',
    sex: 'MALE',
    email: 'test@example.com',
    studentNumber: 1234,
    grade: 1,
    classNumber: 1,
    number: 1,
    role: 'GENERAL_STUDENT',
  );
}
