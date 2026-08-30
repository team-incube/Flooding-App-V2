import 'dart:convert';

import 'package:flooding_v2/core/utils/token_utils.dart';
import 'package:flutter_test/flutter_test.dart';

String _jwt({required DateTime exp}) {
  String segment(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final header = segment({'alg': 'none'});
  final payload = segment({'exp': exp.toUtc().millisecondsSinceEpoch ~/ 1000});
  return '$header.$payload.';
}

void main() {
  group('TokenUtils.isExpired', () {
    test('exp가 미래면 만료 아님', () {
      final token = _jwt(exp: DateTime.now().add(const Duration(hours: 1)));
      expect(TokenUtils.isExpired(token), isFalse);
    });

    test('exp가 과거면 만료', () {
      final token = _jwt(
        exp: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(TokenUtils.isExpired(token), isTrue);
    });

    test('JWT 형식이 아니면 판단 불가 — 만료 아님으로 처리', () {
      expect(TokenUtils.isExpired('not-a-jwt'), isFalse);
    });

    test('exp 클레임이 없으면 판단 불가 — 만료 아님으로 처리', () {
      final header = base64Url
          .encode(utf8.encode(jsonEncode({'alg': 'none'})))
          .replaceAll('=', '');
      final payload = base64Url
          .encode(utf8.encode(jsonEncode({'sub': '1'})))
          .replaceAll('=', '');
      expect(TokenUtils.isExpired('$header.$payload.'), isFalse);
    });
  });
}
