import '../../../../core/enum/gender.dart';

class StudyMemberViewModel {
  final String name;
  final int schoolNb;
  final Gender gender;

  StudyMemberViewModel({
    required this.name,
    required this.schoolNb,
    required this.gender,
  });
}
