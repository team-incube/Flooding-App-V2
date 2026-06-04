import '../../../../core/enum/gender.dart';

class MemberViewModel {
  final String name;
  final int schoolNb;
  final Gender gender;

  MemberViewModel({
    required this.name,
    required this.schoolNb,
    required this.gender,
  });
}
