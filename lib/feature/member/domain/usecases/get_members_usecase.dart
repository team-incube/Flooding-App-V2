import '../../presentation/models/member_model.dart';

abstract class GetMembersUseCase {
  Future<List<MemberModel>> call();
}
