import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_user.freezed.dart';
part 'search_user.g.dart';

/// `GET /users` 학생 검색 결과 한 명(`SearchUsersResponse`).
@freezed
abstract class SearchUser with _$SearchUser {
  const factory SearchUser({
    required int id,
    required String name,
    required String sex,
    required int studentNumber,
    required int grade,
    required int classNumber,
    required int number,
    required String role,
    @Default(false) bool isBanned,
    String? profileImageUrl,
  }) = _SearchUser;

  factory SearchUser.fromJson(Map<String, dynamic> json) =>
      _$SearchUserFromJson(json);
}

/// Spring `Page<SearchUsersResponse>` 페이지네이션 응답.
@freezed
abstract class SearchUsersPage with _$SearchUsersPage {
  const factory SearchUsersPage({
    @Default([]) List<SearchUser> content,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
    @Default(0) int number,
    @Default(0) int size,
    @Default(false) bool first,
    @Default(false) bool last,
  }) = _SearchUsersPage;

  factory SearchUsersPage.fromJson(Map<String, dynamic> json) =>
      _$SearchUsersPageFromJson(json);
}

/// `GET /users` 응답 래퍼(`CommonApiResponse`).
@freezed
abstract class SearchUsersResponse with _$SearchUsersResponse {
  const factory SearchUsersResponse({
    String? status,
    int? code,
    String? message,
    SearchUsersPage? data,
  }) = _SearchUsersResponse;

  factory SearchUsersResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchUsersResponseFromJson(json);
}
