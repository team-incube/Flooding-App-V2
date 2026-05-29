import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_request.freezed.dart';
part 'refresh_request.g.dart';

/// refresh_token → 새 token 발급 요청 본문.
///
/// PKCE 클라이언트이므로 client_secret 은 포함하지 않는다.
@freezed
abstract class RefreshRequest with _$RefreshRequest {
  const factory RefreshRequest({
    @JsonKey(name: 'grant_type') @Default('refresh_token') String grantType,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'client_id') required String clientId,
  }) = _RefreshRequest;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);
}
