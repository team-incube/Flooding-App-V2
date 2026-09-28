import 'package:freezed_annotation/freezed_annotation.dart';

part 'me.freezed.dart';
part 'me.g.dart';

/// `GET /users/me` 응답의 내 정보(`GetMeResponse`).
@freezed
abstract class Me with _$Me {
  const factory Me({
    required int id,
    required String name,
    required String sex,
    required String email,
    required int studentNumber,
    required int grade,
    required int classNumber,
    required int number,
    required String role,
    @Default(0) int penaltyScore,
    @Default(false) bool isBanned,
    @Default(false) bool hasClubApplication,
    int? dormitoryRoom,
    int? dormitoryFloor,
    String? specialty,
    String? profileImageUrl,
  }) = _Me;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);
}

/// `GET /users/me` 응답 래퍼(`CommonApiResponse`).
@freezed
abstract class MeResponse with _$MeResponse {
  const factory MeResponse({
    String? status,
    int? code,
    String? message,
    Me? data,
  }) = _MeResponse;

  factory MeResponse.fromJson(Map<String, dynamic> json) =>
      _$MeResponseFromJson(json);
}
