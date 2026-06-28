import 'package:flooding_v2/core/enum/gender.dart';

class StudentEntity {
  const StudentEntity({
    required this.name,
    required this.grade,
    required this.classNumber,
    required this.number,
    required this.gender,
  });

  final String name;
  final int grade;
  final int classNumber;
  final int number;
  final Gender gender;
}