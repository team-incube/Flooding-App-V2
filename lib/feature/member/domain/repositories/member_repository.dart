import '../../../../core/enum/gender.dart';
import '../../presentation/models/member_model.dart';

//TODO : data 구현 단계에서, abstract class로 새롭게 정의
class MemberRepository {
  MemberRepository();

  final _mockData = List.generate(
    12,
    (index) =>
        MemberModel(name: '김민솔', gender: Gender.female, schoolNb: 2403 + index),
  );

  Future<List<MemberModel>> getStudyMembers() async {
    return _mockData;
  }
}
