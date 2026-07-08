import 'package:flooding_v2/core/enum/gender.dart';
import 'package:flooding_v2/feature/massage/data/models/massage_applicant.dart';
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
        grade: a.studentNumber ~/ 1000,
        classNumber: (a.studentNumber ~/ 100) % 10,
        number: a.studentNumber % 100,
        gender: Gender.getString(null),
      );
}