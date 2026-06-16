import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_response.freezed.dart';
part 'signin_response.g.dart';

/// `/auth/signin` 으로 발급된 Flooding 백엔드 토큰 쌍.
@freezed
abstract class SigninData with _$SigninData {
  const factory SigninData({
    required String accessToken,
    required String refreshToken,
  }) = _SigninData;

  factory SigninData.fromJson(Map<String, dynamic> json) =>
      _$SigninDataFromJson(json);
}

/// `POST /auth/signin` 응답 래퍼(`CommonApiResponse`).
@freezed
abstract class SigninResponse with _$SigninResponse {
  const factory SigninResponse({
    String? status,
    int? code,
    String? message,
    SigninData? data,
  }) = _SigninResponse;

  factory SigninResponse.fromJson(Map<String, dynamic> json) =>
      _$SigninResponseFromJson(json);
}
