import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/search_text_field.dart';
import '../../../member/presentation/blocs/member_list_bloc.dart';
import '../../../member/presentation/blocs/member_list_event.dart';
import '../../../member/presentation/widgets/no_member_icon.dart';
import '../../../member/presentation/widgets/request_member_list_layout.dart';
import '../bloc/study_bloc.dart';
import '../bloc/study_event.dart';
import '../bloc/study_state.dart';

class StudyRequestView extends StatefulWidget {
  const StudyRequestView({super.key});

  @override
  State<StudyRequestView> createState() => _StudyRequestViewState();
}

class _StudyRequestViewState extends State<StudyRequestView> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 셸 진입 시 이미 1회 로드되므로, 화면 진입의 재조회는 인디케이터 없이
    // 값만 갱신한다(refresh).
    context.read<StudyBloc>().add(
      const StudyEvent.applicantsRequested(refresh: true),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudyBloc, StudyState>(
      listenWhen: (prev, curr) =>
          curr.result != null &&
          curr.result != prev.result &&
          curr.result!.isAttendanceAction,
      listener: (context, state) {
        context.read<MemberListBloc>().add(MemberListEvent.load());
      },
      builder: (context, state) {
        final isLoading =
            state.listStatus == StudyListStatus.initial ||
            state.listStatus == StudyListStatus.loading;

        return RequestMemberListLayout(
          title: '자습신청',
          showMedal: true,
          searchBar: SearchTextField(
            textEditingController: searchController,
            hintText: '학생 이름, 학번을 입력해주세요',
          ),
          onCheckIn: (userIds) => context.read<StudyBloc>().add(
            StudyEvent.checkInRequested(userIds: userIds),
          ),
          onCheckOut: (userIds) => context.read<StudyBloc>().add(
            StudyEvent.checkOutRequested(userIds: userIds),
          ),
          emptyIcon: isLoading
              ? const Center(child: AppLoadingIndicator())
              : state.applicantCount > 0
              // 신청자는 있으나 필터 결과만 비어 있는 경우.
              ? NoMemberIcon(
                  icon: AppIcon.graduationCap(size: AppSize.s100),
                  title: '조건에 맞는 학생이 없습니다.',
                  subTitle: '필터 설정을 확인해 주세요.',
                )
              // 전체 신청자가 0명인 경우.
              : NoMemberIcon(
                  icon: AppIcon.graduationCap(size: AppSize.s100),
                  title: '자습 신청한 인원이 없습니다.',
                  subTitle: '자습 신청 시간은 20:00 ~ 21:00에 신청이 가능해요',
                ),
        );
      },
    );
  }
}

