import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/widgets/search_text_field.dart';
import '../../../member/presentation/blocs/member_list_bloc.dart';
import '../../../member/presentation/blocs/member_list_event.dart';
import '../../../member/presentation/blocs/member_list_state.dart';
import '../../../member/presentation/widgets/no_member_icon.dart';
import '../../../member/presentation/widgets/request_member_list_layout.dart';

class StudyRequestView extends StatefulWidget {
  const StudyRequestView({super.key});

  @override
  State<StudyRequestView> createState() => _StudyRequestViewState();
}

class _StudyRequestViewState extends State<StudyRequestView> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberListBloc, MemberListState>(
      builder: (context, state) {
        return RequestMemberListLayout(
          title: '자습신청',
          searchBar: SearchTextField(
            textEditingController: searchController,
            hintText: '학생 이름, 학번을 입력해주세요',
          ),
          filterAction: (grade, classNb, gender) {
            context.read<MemberListBloc>().add(
              MemberListEvent.filter(
                grade: grade,
                classNb: classNb,
                gender: gender,
              ),
            );
          },
          emptyIcon: NoMemberIcon(
            icon: AppIcon.graduationCap(size: AppSize.s100),
            title: '자습 신청한 인원이 없습니다.',
            subTitle: '자습 신청 시간은 20:00 ~ 21:00에 신청이 가능해요',
          ),
          memberList:
              state.whenOrNull(
                loaded: (list) => list,
                filtered: (list) => list,
              ) ??
              [],
        );
      },
    );
  }
}
