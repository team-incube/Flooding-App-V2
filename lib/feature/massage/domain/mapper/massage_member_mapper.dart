import 'package:flooding_v2/core/enum/gender.dart';
import 'package:flooding_v2/feature/massage/data/models/massage_applicant.dart';
import 'package:flooding_v2/feature/member/domain/student_formatter.dart';
import 'package:flooding_v2/feature/member/entities/student_entity.dart';
import 'package:flooding_v2/feature/member/presentation/models/member_model.dart';

class MassageMemberMapper {
  static MemberModel toMember(MassageApplicant a) => MemberModel(
    id: a.studentNumber,
    name: a.name,
    schoolNb: a.studentNumber,
    gender: Gender.getString(null),
  );

  static StudentEntity toEntity(MassageApplicant a) => StudentEntity(
    name: a.name,
    grade: StudentFormatter.parseGrade(a.studentNumber),
    classNumber: StudentFormatter.parseClassNumber(a.studentNumber),
    number: StudentFormatter.parseNumber(a.studentNumber),
    gender: Gender.getString(null),
  );
}
