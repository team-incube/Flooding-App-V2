import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/core/enum/gender.dart';
import 'package:flooding_v2/feature/member/domain/usecases/get_members_usecase.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_bloc.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_event.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_list_state.dart';
import 'package:flooding_v2/feature/member/presentation/models/member_model.dart';

class _FakeGetMembers implements GetMembersUseCase {
  _FakeGetMembers(this.members);

  final List<MemberModel> members;

  @override
  Future<List<MemberModel>> call() async => members;
}

MemberModel _m(String name, int nb) =>
    MemberModel(name: name, schoolNb: nb, gender: Gender.female);

void main() {
  final fresh = [_m('김민솔', 2403), _m('이재현', 1101)];

  test('시드 없이 첫 조회는 loading 인디케이터를 거친다', () async {
    final bloc = MemberListBloc(getMembers: _FakeGetMembers(fresh));
    expect(bloc.state, const MemberListState.initial());

    final statuses = <MemberListState>[];
    final sub = bloc.stream.listen(statuses.add);

    bloc.add(MemberListEvent.load());
    await pumpEventQueue();

    expect(statuses.first, const MemberListState.loading());
    expect(bloc.state, MemberListState.loaded(memberList: fresh));

    await sub.cancel();
    await bloc.close();
  });

  test('시드가 있으면 인디케이터 없이 값만 갱신한다', () async {
    final cached = [_m('박서준', 2401)];
    final bloc = MemberListBloc(
      getMembers: _FakeGetMembers(fresh),
      initialMembers: cached,
    );
    // 시작부터 캐시 목록을 보여준다(초기 인디케이터 없음).
    expect(bloc.state, MemberListState.loaded(memberList: cached));

    final statuses = <MemberListState>[];
    final sub = bloc.stream.listen(statuses.add);

    bloc.add(MemberListEvent.load());
    await pumpEventQueue();

    // loading 을 거치지 않고 곧장 새 값으로만 갱신한다.
    expect(statuses.contains(const MemberListState.loading()), isFalse);
    expect(bloc.state, MemberListState.loaded(memberList: fresh));

    await sub.cancel();
    await bloc.close();
  });
}
