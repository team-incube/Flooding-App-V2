import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/feature/auth/data/datasources/token_storage.dart';
import 'package:flooding_v2/feature/auth/data/user_service.dart';
import 'package:flooding_v2/feature/auth/presentation/auth_controller.dart';

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage({this.token});

  String? token;
  bool cleared = false;

  @override
  Future<bool> hasToken() async => token != null;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> clear() async {
    cleared = true;
    token = null;
  }
}

class _FakeSessionValidator implements SessionValidator {
  _FakeSessionValidator(this.result);

  final SessionCheck result;
  int calls = 0;

  @override
  Future<SessionCheck> validateSession({Duration timeout = Duration.zero}) async {
    calls++;
    return result;
  }
}

AuthController _controller(
  _FakeTokenStorage storage,
  _FakeSessionValidator validator,
) => AuthController(tokenStorage: storage, sessionValidator: validator);

void main() {
  group('AuthController.bootstrap', () {
    test('토큰이 없으면 미인증 (세션 검사 건너뜀)', () async {
      final storage = _FakeTokenStorage(token: null);
      final validator = _FakeSessionValidator(SessionCheck.valid);
      final controller = _controller(storage, validator);

      await controller.bootstrap();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(validator.calls, 0);
    });

    test('토큰이 있고 /users/me 가 유효하면 인증', () async {
      final storage = _FakeTokenStorage(token: 'access');
      final validator = _FakeSessionValidator(SessionCheck.valid);
      final controller = _controller(storage, validator);

      await controller.bootstrap();

      expect(controller.status, AuthStatus.authenticated);
      expect(validator.calls, 1);
      expect(storage.cleared, isFalse);
    });

    test('401 이면 토큰을 비우고 미인증(로그인으로)', () async {
      final storage = _FakeTokenStorage(token: 'expired');
      final validator = _FakeSessionValidator(SessionCheck.unauthorized);
      final controller = _controller(storage, validator);

      await controller.bootstrap();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(storage.cleared, isTrue);
    });

    test('네트워크 등 판단 불가면 진입 허용(토큰 유지)', () async {
      final storage = _FakeTokenStorage(token: 'access');
      final validator = _FakeSessionValidator(SessionCheck.unknown);
      final controller = _controller(storage, validator);

      await controller.bootstrap();

      expect(controller.status, AuthStatus.authenticated);
      expect(storage.cleared, isFalse);
    });
  });

  group('AuthController.expireSession', () {
    test('토큰을 비우고 미인증으로 전환하며 리스너에 알린다', () async {
      final storage = _FakeTokenStorage(token: 'access');
      final controller = _controller(
        storage,
        _FakeSessionValidator(SessionCheck.valid),
      );
      var notified = false;
      controller.addListener(() => notified = true);

      await controller.expireSession();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(storage.cleared, isTrue);
      expect(notified, isTrue);
    });
  });
}
