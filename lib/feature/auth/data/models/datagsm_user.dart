import 'package:freezed_annotation/freezed_annotation.dart';

import 'student_role.dart';

part 'datagsm_user.freezed.dart';
part 'datagsm_user.g.dart';

/// DataGSM userinfo 응답.
@freezed
abstract class DatagsmUser with _$DatagsmUser {
  const factory DatagsmUser({
    required int id,
    required String email,
    required String role,
    @JsonKey(name: 'isStudent') @Default(false) bool isStudent,
    DatagsmStudent? student,
  }) = _DatagsmUser;

  factory DatagsmUser.fromJson(Map<String, dynamic> json) =>
      _$DatagsmUserFromJson(json);
}

/// 학생 사용자의 상세 정보(`isStudent` 가 true 일 때 제공).
@freezed
abstract class DatagsmStudent with _$DatagsmStudent {
  const factory DatagsmStudent({
    required int id,
    required String name,
    required int grade,
    required int classNum,
    required int number,
    required int studentNumber,
    String? sex,
    String? major,
    String? specialty,
    int? dormitoryFloor,
    int? dormitoryRoom,
    @JsonKey(unknownEnumValue: StudentRole.genderalStudent) StudentRole? role,
    @JsonKey(name: 'isLeaveSchool') @Default(false) bool isLeaveSchool,
  }) = _DatagsmStudent;

  factory DatagsmStudent.fromJson(Map<String, dynamic> json) =>
      _$DatagsmStudentFromJson(json);
}
