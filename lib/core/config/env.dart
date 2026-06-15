import 'package:flutter_dotenv/flutter_dotenv.dart';

/// `.env.dev.{flavor}` 로부터 로드한 환경 값에 접근하는 진입점.
///
/// 빌드 시 `--dart-define=ENV=prod` 로 환경을 전환한다(기본 dev).
/// 비밀이 아닌 값만 보관한다 — PKCE 방식이라 client_secret 은 포함하지 않는다.
class Env {
  Env._();

  static const String flavor = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// `main` 에서 앱 시작 전 1회 호출한다.
  static Future<void> load() => dotenv.load(fileName: '.env.$flavor');

  /// Flooding 백엔드 base URL.
  static String get apiBaseUrl => dotenv.get('API_BASE_URL');

  static String get datagsmClientId => dotenv.get('DATAGSM_CLIENT_ID');

  static String get datagsmRedirectUri => dotenv.get('DATAGSM_REDIRECT_URI');
}
