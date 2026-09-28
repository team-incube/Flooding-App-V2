import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_request.freezed.dart';
part 'signin_request.g.dart';

/// `POST /auth/signin` 요청 본문 — OAuth 인가 코드로 로그인한다.
@freezed
abstract class SigninRequest with _$SigninRequest {
  const factory SigninRequest({
    required String authCode,
    required String redirectUri,
  }) = _SigninRequest;

  factory SigninRequest.fromJson(Map<String, dynamic> json) =>
      _$SigninRequestFromJson(json);
}
