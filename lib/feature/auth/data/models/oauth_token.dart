import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth_token.freezed.dart';
part 'oauth_token.g.dart';

/// DataGSM token 엔드포인트 응답.
///
/// access_token 1시간, refresh_token 30일 유효.
@freezed
abstract class OAuthToken with _$OAuthToken {
  const factory OAuthToken({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') @Default('Bearer') String tokenType,
    @JsonKey(name: 'expires_in') @Default(3600) int expiresIn,
    String? scope,
  }) = _OAuthToken;

  factory OAuthToken.fromJson(Map<String, dynamic> json) =>
      _$OAuthTokenFromJson(json);
}
