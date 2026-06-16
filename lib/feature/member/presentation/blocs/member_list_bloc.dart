import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_members_usecase.dart';
import '../../../../core/enum/gender.dart';
import '../models/member_model.dart';
import 'member_list_event.dart';
import 'member_list_state.dart';

class MemberListBloc extends Bloc<MemberListEvent, MemberListState> {
  MemberListBloc({required GetMembersUseCase getMembers})
    : _getMembers = getMembers,
      super(const MemberListState.initial()) {
    on<MemberListEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        load: () => _onLoad(emit),
        filter: (grade, classNb, gender) =>
            _onFilter(emit, grade, classNb, gender),
      );
    });
  }

  final GetMembersUseCase _getMembers;
  List<MemberModel> _allMembers = [];

  Future<void> _onLoad(Emitter<MemberListState> emit) async {
    emit(const MemberListState.loading());
    try {
      _allMembers = await _getMembers();
      emit(MemberListState.loaded(memberList: _allMembers));
    } on Exception catch (e) {
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
