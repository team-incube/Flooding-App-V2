import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/oauth_token.dart';

/// access/refresh 토큰을 보안 저장소(Keychain/Keystore)에 보관한다.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _accessKey = 'datagsm_access_token';
  static const String _refreshKey = 'datagsm_refresh_token';

  Future<void> save(OAuthToken token) async {
    await _storage.write(key: _accessKey, value: token.accessToken);
    await _storage.write(key: _refreshKey, value: token.refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<bool> hasToken() async => (await readAccessToken()) != null;

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
