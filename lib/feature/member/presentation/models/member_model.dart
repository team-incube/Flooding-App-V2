import '../../../../core/enum/gender.dart';

class MemberModel {
  final String name;
  final int schoolNb;
  final Gender gender;

  MemberModel({
    required this.name,
    required this.schoolNb,
    required this.gender,
  });
}
