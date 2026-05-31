import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_request.freezed.dart';
part 'token_request.g.dart';

/// authorization code → token 교환 요청 본문(PKCE).
@freezed
abstract class TokenRequest with _$TokenRequest {
  const factory TokenRequest({
    @JsonKey(name: 'grant_type')
    @Default('authorization_code')
    String grantType,
    required String code,
    @JsonKey(name: 'client_id') required String clientId,
    @JsonKey(name: 'redirect_uri') required String redirectUri,
    @JsonKey(name: 'code_verifier') required String codeVerifier,
  }) = _TokenRequest;

  factory TokenRequest.fromJson(Map<String, dynamic> json) =>
      _$TokenRequestFromJson(json);
}
