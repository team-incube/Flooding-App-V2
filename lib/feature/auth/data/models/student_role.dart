import 'package:json_annotation/json_annotation.dart';

import '../../../../core/enum/role.dart';

/// DataGSM 이 내려주는 학생 role 원본 값.
enum StudentRole {
  @JsonValue('DORMITORY_MANAGER')
  dormitoryManager,
  @JsonValue('GENERAL_STUDENT')
  generalStudent,
  @JsonValue('STUDENT_COUNCIL')
  studentCouncil,
  @JsonValue('GRADUATE')
  graduate,
  @JsonValue('WITHDRAWN')
  withdrawn;

  Role get toRole => switch (this) {
    dormitoryManager => Role.dormitoryManager,
    _ => Role.generalStudent,
  };
}
