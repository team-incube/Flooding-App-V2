import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/widgets/search_text_field.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/enum/gender.dart';
import '../../../../core/widgets/base_scaffold.dart';
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

    final topLine = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: Row(
        children: [
          iconButton(AppIcon.chevronLeft(), () {}),
          const SizedBox(width: AppSpacing.s4),
          Text(
            "자습신청",
            style: AppTextStyle.text1.copyWith(color: AppColors.lightMainText),
          ),
          const Spacer(),
          iconButton(AppIcon.filter(), () {}),
        ],
      ),
    );

    return BaseScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        child: Column(
          children: [
            topLine,

            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s16,
                      ),
                      child: SearchTextField(
                        textEditingController: textEditingController,
                        hintText: '학생 이름, 학번을 입력해주세요',
                      ),
                    ),
                  ),

                  _MemberGridLayout(memberList: memberList),
                ],
              ),
            ),
          ],
        ),
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
