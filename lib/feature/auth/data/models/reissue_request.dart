import 'package:freezed_annotation/freezed_annotation.dart';

part 'reissue_request.freezed.dart';
part 'reissue_request.g.dart';

/// `POST /auth/reissue` 요청 본문 — refresh token 으로 토큰을 재발급한다.
@freezed
abstract class ReissueRequest with _$ReissueRequest {
  const factory ReissueRequest({required String refreshToken}) = _ReissueRequest;

  factory ReissueRequest.fromJson(Map<String, dynamic> json) =>
      _$ReissueRequestFromJson(json);
}
