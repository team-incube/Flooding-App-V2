import '../repositories/member_repository.dart';
import 'get_members_usecase.dart';
import '../../presentation/models/member_model.dart';

class GetMassageMembersUseCase implements GetMembersUseCase {
  const GetMassageMembersUseCase(this._repository);

  final MemberRepository _repository;

  @override
  Future<List<MemberModel>> call() => _repository.getMassageMembers();
}
