import '../../../../core/enum/gender.dart';

class MemberModel {
  final int id;
  final String name;
  final int schoolNb;
  final Gender gender;

  /// 출석(체크인) 완료 여부 — 자습 외 기능(안마의자 등)은 항상 false.
  final bool isAttended;

  MemberModel({
    required this.id,
    required this.name,
    required this.schoolNb,
    required this.gender,
    this.isAttended = false,
  });
}
