import 'dart:convert';

/// JWT access/refresh 토큰의 만료 여부를 서버 호출 없이 로컬에서 판단한다.
///
/// `exp` 클레임을 읽지 못하는 토큰(형식이 다르거나 파싱 실패)은 만료로
/// 간주하지 않는다 — 판단 불가를 이유로 사용자를 로그인 화면으로 보내지
/// 않기 위함이며, 실제 만료는 서버가 401로 알려주면 그때 갱신·처리한다.
class TokenUtils {
  const TokenUtils._();

  static bool isExpired(String token, {DateTime? now}) {
    final expiration = getExpiration(token);
    if (expiration == null) return false;
    return !expiration.isAfter(now ?? DateTime.now());
  }

  static DateTime? getExpiration(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;

      final exp = decoded['exp'];
      final seconds = switch (exp) {
        num n => n.toInt(),
        String s => int.tryParse(s),
        _ => null,
      };
      if (seconds == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000,
        isUtc: true,
      ).toLocal();
    } catch (_) {
      return null;
    }
  }
}
