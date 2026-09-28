import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_image_response.freezed.dart';
part 'profile_image_response.g.dart';

/// `POST /users/me/profile-image` 응답 래퍼(`CommonApiResponse`).
@freezed
abstract class ProfileImageResponse with _$ProfileImageResponse {
  const factory ProfileImageResponse({
    String? status,
    int? code,
    String? message,
    ProfileImageData? data,
  }) = _ProfileImageResponse;

  factory ProfileImageResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageResponseFromJson(json);
}

/// 업로드 성공 시 사용할 프로필 이미지 URL.
@freezed
abstract class ProfileImageData with _$ProfileImageData {
  const factory ProfileImageData({String? profileImageUrl}) = _ProfileImageData;

  factory ProfileImageData.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageDataFromJson(json);
}
