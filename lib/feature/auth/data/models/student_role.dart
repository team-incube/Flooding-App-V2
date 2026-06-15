import 'package:json_annotation/json_annotation.dart';

/// DataGSM 이 내려주는 학생 role 원본 값.
enum StudentRole {
  @JsonValue('DORMITORY_MANAGER')
  dormitoryManager,
  @JsonValue('GENERAL_STUDENT')
  genderalStudent,
  @JsonValue('STUDENT_COUNCIL')
  studentCouncil,
  @JsonValue('GRADUATE')
  graduate,
  @JsonValue('WITHDRAWN')
  withdrawn,
}
