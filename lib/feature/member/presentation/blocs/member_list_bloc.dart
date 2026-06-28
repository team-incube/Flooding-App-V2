import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_members_usecase.dart';
import '../../../../core/enum/gender.dart';
import '../models/member_model.dart';
import 'member_list_event.dart';
import 'member_list_state.dart';

class MemberListBloc extends Bloc<MemberListEvent, MemberListState> {
  /// [initialMembers] 를 주면(셸 캐시 등) 인디케이터 없이 그 목록으로 시작하고,
  /// 이후 조회는 화면을 유지한 채 값만 갱신한다. null 이면 첫 조회에서
  /// 로딩 인디케이터를 노출한다(빈 목록 시드와 미시드를 구분하기 위해 nullable).
  MemberListBloc({
    required GetMembersUseCase getMembers,
    List<MemberModel>? initialMembers,
  }) : _getMembers = getMembers,
       _allMembers = initialMembers ?? const [],
       super(
         initialMembers == null
             ? const MemberListState.initial()
             : MemberListState.loaded(memberList: initialMembers),
       ) {
    on<MemberListEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        load: () => _onLoad(emit),
        filter: (grade, classNb, gender) =>
            _onFilter(emit, grade, classNb, gender),
      );
    });
  }

  final GetMembersUseCase _getMembers;
  List<MemberModel> _allMembers;

  Future<void> _onLoad(Emitter<MemberListState> emit) async {
    // 아직 보여줄 목록이 없을 때(initial)만 인디케이터를 띄운다. 시드/재조회는
    // 기존 목록을 유지한 채 값만 갱신해 깜빡임을 막는다.
    final isInitial = state.maybeWhen(initial: () => true, orElse: () => false);
    if (isInitial) emit(const MemberListState.loading());
    try {
      _allMembers = await _getMembers();
      emit(MemberListState.loaded(memberList: _allMembers));
    } on Exception catch (e) {
      // 이미 목록을 보여주고 있었다면(시드/재조회) 화면을 비우지 않고 유지한다.
      if (!isInitial) return;
      _allMembers = [];
      emit(MemberListState.error(message: _messageOf(e)));
    }
  }

  String _messageOf(Exception e) {
    final raw = e.toString();
    final stripped = raw.startsWith('Exception: ')
        ? raw.substring('Exception: '.length)
        : raw;
    return stripped.isEmpty ? '목록을 불러오지 못했어요.' : stripped;
  }

  void _onFilter(
    Emitter<MemberListState> emit,
    int? grade,
    int? classNb,
    Gender? gender,
  ) {
    if (_allMembers.isEmpty) return;

    Iterable<MemberModel> filtered = _allMembers;

    if (grade != null) {
      filtered = filtered.where((m) => grade == m.schoolNb ~/ 1000);
    }
    if (classNb != null) {
      filtered = filtered.where((m) => classNb == (m.schoolNb ~/ 100) % 10);
    }
    if (gender != null) {
      filtered = filtered.where((m) => gender == m.gender);
    }

    emit(MemberListState.filtered(memberList: filtered.toList()));
  }
}
