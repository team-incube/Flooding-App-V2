import 'package:flutter/material.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/enum/gender.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/widgets/search_text_field.dart';
import '../../member/presentation/models/member_model.dart';
import '../../member/presentation/widgets/no_member_icon.dart';
import '../../member/presentation/widgets/request_member_list_layout.dart';

class MassageRequestView extends StatefulWidget {
  const MassageRequestView({super.key});

  @override
  State<MassageRequestView> createState() => _MassageRequestViewState();
}

class _MassageRequestViewState extends State<MassageRequestView> {
  final TextEditingController searchController = TextEditingController();

  //TODO Controller에서 멤버 리스트 불러오기
  final List<MemberModel> memberList = List.generate(
    12,
        (index) =>
        MemberModel(
          name: '김민솔',
          gender: Gender.female,
          schoolNb: 2403 + index,
        ),
  );

  final List<MemberModel> viewMemberList = [];

  @override
  void initState() {
    super.initState();
    viewMemberList.addAll(memberList);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filteringMemberList(int? grade, int? classNb, Gender? gender) {
    Iterable<MemberModel> filtered = memberList;

    if (grade != null) {
      filtered = filtered.where((member) => grade == member.schoolNb ~/ 1000);
    }
    if (classNb != null) {
      filtered = filtered.where(
            (member) => classNb == (member.schoolNb ~/ 100) % 10,
      );
    }
    if (gender != null) {
      filtered = filtered.where((member) => gender == member.gender);
    }

    setState(() {
      viewMemberList.clear();
      viewMemberList.addAll(filtered);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RequestMemberListLayout(
      title: '안마의자 신청',
      searchBar: SearchTextField(
        textEditingController: searchController,
        hintText: '학생 이름, 학번을 입력해주세요',
      ),
      filterAction: _filteringMemberList,
      emptyIcon: NoMemberIcon(
        icon: AppIcon.chair(size: AppSize.s100),
        title: '안마의자를 신청한 인원이 없습니다.',
        subTitle: '안마 의자 신청 시간은 20:20 ~ 21:00에 신청이 가능해요',
        tipTitle: '※ 여학생의 경우 여자 사감선생님께 별도로 신청해주시기 바랍니다.',
      ),
      memberList: viewMemberList,
      isEmpty: memberList.isEmpty,
    );
  }
}
