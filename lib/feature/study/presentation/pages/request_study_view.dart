import 'package:flooding_v2/core/constants/app_size.dart';
import 'package:flooding_v2/core/utils/logger.dart';
import 'package:flooding_v2/core/widgets/sheet/app_confirm_dialog.dart';
import 'package:flooding_v2/feature/study/presentation/widgets/member_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/enum/gender.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/search_text_field.dart';
import '../view_models/study_member_view_model.dart';
import '../widgets/member_card.dart';

class RequestStudyView extends StatefulWidget {
  const RequestStudyView({super.key});

  @override
  State<RequestStudyView> createState() => _RequestStudyViewState();
}

class _RequestStudyViewState extends State<RequestStudyView> {
  final TextEditingController textEditingController = TextEditingController();

  //TODO Controlle에서 멤버 리스트 불러오기
  final List<StudyMemberViewModel> memberList = List.filled(
    12,
    StudyMemberViewModel(name: '김민솔', gender: Gender.female, schoolNb: 2403),
  );

  final List<StudyMemberViewModel> viewMemberList = [];

  @override
  void initState() {
    super.initState();
    viewMemberList.addAll(memberList);
  }

  void _filteringMemberList(BuildContext context) {
    MemberFilterDialog(
      onSubmit: (grade, classNb, gender) {
        final gradeResult = [];
        final classResult = [];
        final genderResult = [];

        if (grade != null) {
          gradeResult.addAll(
            memberList.where(
              (member) => grade == int.tryParse(member.schoolNb.toString()[1]),
            ),
          );
          Logger.d('grade 필터 조회 결과 : $gradeResult');
        }
        if (classNb != null) {
          gradeResult.addAll(
            memberList.where(
              (member) =>
                  classNb == int.tryParse(member.schoolNb.toString()[2]),
            ),
          );
          Logger.d('classNb 필터 조회 결과 : $classResult');
        }
        if (gender != null) {
          gradeResult.addAll(
            memberList.where((member) => gender == member.gender),
          );
          Logger.d('gender 필터 조회 결과 : $genderResult');
        }

        setState(() {
          viewMemberList.clear();
          viewMemberList.addAll({
            ...gradeResult,
            ...classResult,
            ...genderResult,
          });
        });
      },
    ).show(context);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconButton(Widget icon, VoidCallback onTap) => IconButton(
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onTap,
      icon: icon,
    );

    final titleBar = SliverAppBar(
      leading: iconButton(AppIcon.chevronLeft(), () {
        context.pop();
      }),
      leadingWidth: AppSize.s24,
      centerTitle: false,
      titleSpacing: AppSpacing.s4,
      title: Text(
        "자습신청",
        style: AppTextStyle.text1.copyWith(color: AppColors.lightMainText),
      ),
      actions: [
        iconButton(AppIcon.filter(), () => _filteringMemberList(context)),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.s84),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
          child: SearchTextField(
            textEditingController: textEditingController,
            hintText: '학생 이름, 학번을 입력해주세요',
          ),
        ),
      ),
      toolbarHeight: AppSize.s32,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      floating: true,
      snap: true,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          titleBar,
          _MemberGridLayout(memberList: viewMemberList),
          const SliverFillRemaining(),
        ],
      ),
    );
  }
}

class _MemberGridLayout extends StatelessWidget {
  const _MemberGridLayout({required this.memberList});

  final List<StudyMemberViewModel> memberList;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.s8,
        crossAxisSpacing: AppSpacing.s8,
        mainAxisExtent: MemberCard.fixedSize.height,
      ),
      itemCount: memberList.length,
      itemBuilder: (BuildContext context, int index) {
        final member = memberList[index];
        return MemberCard(number: index + 1, model: member);
      },
    );
  }
}
