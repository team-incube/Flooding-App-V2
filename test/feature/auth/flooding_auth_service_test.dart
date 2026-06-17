import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/feature/auth/data/datagsm_auth_service.dart'
    show AuthException;
import 'package:flooding_v2/feature/auth/data/datasources/flooding_auth_api.dart';
import 'package:flooding_v2/feature/auth/data/flooding_auth_service.dart';
import 'package:flooding_v2/feature/auth/data/models/reissue_request.dart';
import 'package:flooding_v2/feature/auth/data/models/signin_request.dart';
import 'package:flooding_v2/feature/auth/data/models/signin_response.dart';

class _FakeFloodingAuthApi implements FloodingAuthApi {
  _FakeFloodingAuthApi({this.response, this.error});

  final SigninResponse? response;
  final Object? error;
  SigninRequest? lastRequest;
  ReissueRequest? lastReissue;

  @override
  Future<SigninResponse> signin(SigninRequest request) async {
    lastRequest = request;
    if (error != null) throw error!;
    return response!;
  }

  @override
  Future<SigninResponse> reissue(ReissueRequest request) async {
    lastReissue = request;
    if (error != null) throw error!;
    return response!;
  }
}

DioException _http(int status) => DioException(
  requestOptions: RequestOptions(path: '/auth/signin'),
  response: Response(
    requestOptions: RequestOptions(path: '/auth/signin'),
    statusCode: status,
  ),
);

void main() {
  group('FloodingAuthService.signin', () {
    test('성공 시 토큰을 반환하고 authCode/redirectUri 를 전달한다', () async {
      final api = _FakeFloodingAuthApi(
        response: const SigninResponse(
          status: 'OK',
          code: 200,
          data: SigninData(accessToken: 'AT', refreshToken: 'RT'),
        ),
      );
      final service = FloodingAuthService(api: api);

      final tokens = await service.signin(
        authCode: 'code-123',
        redirectUri: 'app://callback',
      );

      expect(tokens.accessToken, 'AT');
      expect(tokens.refreshToken, 'RT');
      expect(api.lastRequest?.authCode, 'code-123');
      expect(api.lastRequest?.redirectUri, 'app://callback');
    });

    test('403(학생 아님)은 AuthException 으로 변환한다', () async {
      final service = FloodingAuthService(
        api: _FakeFloodingAuthApi(error: _http(403)),
      );

      expect(
        () => service.signin(authCode: 'c', redirectUri: 'r'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('학생'),
          ),
        ),
      );
    });

    test('data 가 비면 AuthException', () async {
      final service = FloodingAuthService(
        api: _FakeFloodingAuthApi(
          response: const SigninResponse(status: 'OK', code: 200),
        ),
      );

      expect(
        () => service.signin(authCode: 'c', redirectUri: 'r'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('FloodingAuthService.reissue', () {
    test('성공 시 새 토큰을 반환하고 refreshToken 을 전달한다', () async {
      final api = _FakeFloodingAuthApi(
        response: const SigninResponse(
          status: 'OK',
          code: 200,
          data: SigninData(accessToken: 'newAT', refreshToken: 'newRT'),
        ),
      );
      final service = FloodingAuthService(api: api);

      final tokens = await service.reissue(refreshToken: 'oldRT');

      expect(tokens.accessToken, 'newAT');
      expect(tokens.refreshToken, 'newRT');
      expect(api.lastReissue?.refreshToken, 'oldRT');
    });

    test('401(유효하지 않은 refresh)은 AuthException 으로 변환한다', () async {
      final service = FloodingAuthService(
        api: _FakeFloodingAuthApi(error: _http(401)),
      );

      expect(
        () => service.reissue(refreshToken: 'bad'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
