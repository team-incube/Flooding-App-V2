import 'package:flooding_v2/core/enum/gender.dart';
import 'package:flooding_v2/feature/study/data/models/study_applicant.dart';
import 'package:flooding_v2/feature/member/entities/student_entity.dart';
import 'package:flooding_v2/feature/member/domain/student_formatter.dart';
import 'package:flooding_v2/feature/member/presentation/models/member_model.dart';

class StudyMemberMapper {
  static MemberModel toMember(StudyApplicant a) => MemberModel(
        name: a.name,
        schoolNb: StudentFormatter.formatSchoolNumber(
          grade: a.grade,
          classNumber: a.classNumber,
          number: a.number,
          studentNumber: a.studentNumber,
        ),
        gender: Gender.getString(a.sex),
      );

  static StudentEntity toEntity(StudyApplicant a) => StudentEntity(
        name: a.name,
        grade: a.grade ?? 0,
        classNumber: a.classNumber ?? 0,
        number: a.number ?? 0,
        gender: Gender.getString(a.sex),
      );
}
