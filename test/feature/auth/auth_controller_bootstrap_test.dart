import 'package:flooding_v2/feature/auth/presentation/bloc/me_bloc.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_event.dart';
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
  Future<SessionCheck> validateSession({
    Duration timeout = Duration.zero,
  }) async {
    calls++;
    return result;
  }
}

class _FakeUserService extends UserService {
  _FakeUserService() : super();
}

class _FakeMeBloc extends MeBloc {
  _FakeMeBloc() : super(userService: _FakeUserService());

  final addedEvents = <MeEvent>[];

  @override
  void add(MeEvent event) => addedEvents.add(event);
}

AuthController _controller(
  _FakeTokenStorage storage,
  _FakeSessionValidator validator,
  _FakeMeBloc meBloc,
) => AuthController(tokenStorage: storage, sessionValidator: validator, meBloc: meBloc);

void main() {
  group('AuthController.bootstrap', () {
    test('토큰이 없으면 미인증 (세션 검사 건너뜀)', () async {
      final storage = _FakeTokenStorage(token: null);
      final validator = _FakeSessionValidator(SessionCheck.valid);
      final meBloc = _FakeMeBloc();
      final controller = _controller(storage, validator, meBloc);

      await controller.bootstrap();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(validator.calls, 0);
      expect(meBloc.addedEvents, isEmpty);
    });

    test('토큰이 있고 /users/me 가 유효하면 인증 후 MeEvent.load 발행', () async {
      final storage = _FakeTokenStorage(token: 'access');
      final validator = _FakeSessionValidator(SessionCheck.valid);
      final meBloc = _FakeMeBloc();
      final controller = _controller(storage, validator, meBloc);

      await controller.bootstrap();

      expect(controller.status, AuthStatus.authenticated);
      expect(validator.calls, 1);
      expect(storage.cleared, isFalse);
      expect(meBloc.addedEvents, [const MeEvent.requested()]);
    });

    test('401 이면 토큰을 비우고 미인증(로그인으로)', () async {
      final storage = _FakeTokenStorage(token: 'expired');
      final validator = _FakeSessionValidator(SessionCheck.unauthorized);
      final meBloc = _FakeMeBloc();
      final controller = _controller(storage, validator, meBloc);

      await controller.bootstrap();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(storage.cleared, isTrue);
      expect(meBloc.addedEvents, isEmpty);
    });

    test('서버 5xx 등 판단 불가면 진입 허용(토큰 유지)', () async {
      final storage = _FakeTokenStorage(token: 'access');
      final validator = _FakeSessionValidator(SessionCheck.unknown);
      final meBloc = _FakeMeBloc();
      final controller = _controller(storage, validator, meBloc);

      await controller.bootstrap();

      expect(controller.status, AuthStatus.authenticated);
      expect(storage.cleared, isFalse);
      expect(meBloc.addedEvents, [const MeEvent.requested()]);
    });

    test('네트워크 오류면 미인증(로그인 화면) + 오류 메시지, 토큰은 유지', () async {
      final storage = _FakeTokenStorage(token: 'access');
      final validator = _FakeSessionValidator(SessionCheck.networkError);
      final controller = _controller(storage, validator, _FakeMeBloc());

      await controller.bootstrap();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.error, '네트워크 연결을 확인해 주세요.');
      expect(storage.cleared, isFalse);
    });
  });

  group('AuthController.reportNetworkError', () {
    test('인증 상태에서 호출하면 미인증으로 전환하고 오류 메시지를 남긴다', () async {
      final storage = _FakeTokenStorage(token: 'access');
      final controller = _controller(
        storage,
        _FakeSessionValidator(SessionCheck.valid),
        _FakeMeBloc(),
      );
      await controller.bootstrap();
      expect(controller.status, AuthStatus.authenticated);

      controller.reportNetworkError();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.error, '네트워크 연결을 확인해 주세요.');
      // 토큰은 유효할 수 있으므로 지우지 않는다.
      expect(storage.cleared, isFalse);
    });

    test('이미 미인증이면 아무 것도 하지 않는다(중복 알림 방지)', () async {
      final storage = _FakeTokenStorage(token: null);
      final controller = _controller(
        storage,
        _FakeSessionValidator(SessionCheck.valid),
        _FakeMeBloc(),
      );
      await controller.bootstrap();
      expect(controller.status, AuthStatus.unauthenticated);

      var notified = false;
      controller.addListener(() => notified = true);
      controller.reportNetworkError();

      expect(notified, isFalse);
    });
  });

  group('AuthController.expireSession', () {
    test('토큰을 비우고 미인증으로 전환하며 MeEvent.clear 발행', () async {
      final storage = _FakeTokenStorage(token: 'access');
      final meBloc = _FakeMeBloc();
      final controller = _controller(
        storage,
        _FakeSessionValidator(SessionCheck.valid),
        meBloc,
      );
      var notified = false;
      controller.addListener(() => notified = true);

      await controller.expireSession();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(storage.cleared, isTrue);
      expect(notified, isTrue);
      expect(meBloc.addedEvents, [const MeEvent.cleared()]);
    });
  });
}
