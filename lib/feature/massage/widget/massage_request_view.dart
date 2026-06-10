import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/widgets/search_text_field.dart';
import '../../member/presentation/blocs/member_list_bloc.dart';
import '../../member/presentation/blocs/member_list_event.dart';
import '../../member/presentation/blocs/member_list_state.dart';
import '../../member/presentation/widgets/no_member_icon.dart';
import '../../member/presentation/widgets/request_member_list_layout.dart';

class MassageRequestView extends StatefulWidget {
  const MassageRequestView({super.key});

  @override
  State<MassageRequestView> createState() => _MassageRequestViewState();
}

class _MassageRequestViewState extends State<MassageRequestView> {
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
          title: '안마의자 신청',
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
            icon: AppIcon.chair(size: AppSize.s100),
            title: '안마의자를 신청한 인원이 없습니다.',
            subTitle: '안마 의자 신청 시간은 20:20 ~ 21:00에 신청이 가능해요',
            tipTitle: '※ 여학생의 경우 여자 사감선생님께 별도로 신청해주시기 바랍니다.',
          ),
          memberList: state.whenOrNull(
                loaded: (list) => list,
                filtered: (list) => list,
              ) ??
              [],
          isEmpty: state.whenOrNull(empty: () => true) ?? false,
        );
      },
    );
  }
}
