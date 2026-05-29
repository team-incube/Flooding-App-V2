import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// OAuth PKCE/CSRF 파라미터 묶음.
///
/// [verifier] 는 토큰 교환 시 전송하고, [challenge] 는 authorize 요청에,
/// [state] 는 콜백 검증(CSRF 방지)에 사용한다.
class PkcePair {
  const PkcePair({
    required this.verifier,
    required this.challenge,
    required this.state,
  });

  final String verifier;
  final String challenge;
  final String state;
}

/// PKCE 파라미터 생성기.
///
/// DataGSM 규격: code_verifier 는 43~128자 `[A-Za-z0-9-._~]`,
/// code_challenge 는 `base64url(sha256(verifier))` (패딩 제거), method `S256`.
class Pkce {
  Pkce._();

  static const String _unreserved =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  static const String challengeMethod = 'S256';

  static PkcePair generate() {
    final verifier = _randomString(64);
    final challenge = _base64UrlNoPad(
      sha256.convert(ascii.encode(verifier)).bytes,
    );
    final state = _randomString(32);
    return PkcePair(verifier: verifier, challenge: challenge, state: state);
  }

  static String _randomString(int length) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => _unreserved[random.nextInt(_unreserved.length)],
    ).join();
  }

  static String _base64UrlNoPad(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
