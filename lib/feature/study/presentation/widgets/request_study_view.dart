import 'package:flutter/material.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/enum/gender.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/widgets/search_text_field.dart';
import '../../../member/widgets/no_member_icon.dart';
import '../../../member/widgets/request_member_list_layout.dart';
import '../../../member/view_models/member_view_model.dart';

class RequestStudyView extends StatefulWidget {
  const RequestStudyView({super.key});

  @override
  State<RequestStudyView> createState() => _RequestStudyViewState();
}

class _RequestStudyViewState extends State<RequestStudyView> {
  final TextEditingController searchController = TextEditingController();

  //TODO Controlle에서 멤버 리스트 불러오기
  final List<MemberViewModel> memberList = List.generate(
    12,
    (index) => MemberViewModel(
      name: '김민솔',
      gender: Gender.female,
      schoolNb: 2403 + index,
    ),
  );

  final List<MemberViewModel> viewMemberList = [];

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
    Iterable<MemberViewModel> filtered = memberList;

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
      title: '자습신청',
      searchBar: SearchTextField(
        textEditingController: searchController,
        hintText: '학생 이름, 학번을 입력해주세요',
      ),
      filterAction: _filteringMemberList,
      emptyIcon: NoMemberIcon(
        icon: AppIcon.graduationCap(size: AppSize.s100),
        title: '자습 신청한 인원이 없습니다.',
        subTitle: '자습 신청 시간은 20:00 ~ 21:00에 신청이 가능해요',
      ),
      memberList: viewMemberList,
    );
  }
}
