import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// `.env.{flavor}` 로부터 로드한 환경 값에 접근하는 진입점.
///
/// 빌드 시 `flutter run --flavor prod` 로 환경을 전환한다(기본 dev).
/// 실제 빌드 flavor(`appFlavor`)를 그대로 읽으므로 별도 `--dart-define` 은 필요 없다.
/// (테스트 등 flavor 없이 실행되는 경우 `appFlavor` 가 null 이라 dev 로 폴백한다.)
/// 비밀이 아닌 값만 보관한다 — PKCE 방식이라 client_secret 은 포함하지 않는다.
class Env {
  Env._();

  static String? _overrideFlavor;
  static set overrideFlavor(String? value) => _overrideFlavor = value;
  static String get flavor => _overrideFlavor ?? appFlavor ?? 'dev';

  /// `main` 에서 앱 시작 전 1회 호출한다.
  static Future<void> load() => dotenv.load(fileName: '.env.$flavor');

  /// Flooding 백엔드 base URL.
  static String get apiBaseUrl => dotenv.get('API_BASE_URL');

  static String get datagsmClientId => dotenv.get('DATAGSM_CLIENT_ID');

  static String get datagsmRedirectUri => dotenv.get('DATAGSM_REDIRECT_URI');
}
