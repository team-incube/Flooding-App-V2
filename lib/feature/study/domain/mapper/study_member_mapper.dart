import 'package:flooding_v2/core/enum/gender.dart';
import 'package:flooding_v2/feature/study/data/models/study_applicant.dart';
import 'package:flooding_v2/feature/member/entities/student_entity.dart';
import 'package:flooding_v2/feature/member/domain/student_formatter.dart';
import 'package:flooding_v2/feature/member/presentation/models/member_model.dart';

class StudyMemberMapper {
  static MemberModel toMember(StudyApplicant a) => MemberModel(
        id: a.id,
        name: a.name,
        schoolNb: StudentFormatter.formatSchoolNumber(
          grade: a.grade,
          classNumber: a.classNumber,
          number: a.number,
          studentNumber: a.studentNumber,
        ),
        gender: Gender.getString(a.sex),
        isAttended: a.isAttended ?? false,
      );

  static StudentEntity toEntity(StudyApplicant a) => StudentEntity(
        name: a.name,
        // 학년/반/번호가 비어 있으면 학번(studentNumber)에서 역산한다.
        grade: a.grade ?? a.studentNumber ~/ 1000,
        classNumber: a.classNumber ?? (a.studentNumber ~/ 100) % 10,
        number: a.number ?? a.studentNumber % 100,
        gender: Gender.getString(a.sex),
      );
}
