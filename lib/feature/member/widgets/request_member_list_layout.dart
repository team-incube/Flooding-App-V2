import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_size.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/color/app_colors.dart';
import '../../../core/theme/icon/app_icon.dart';
import '../../../core/theme/text_style/app_text_style.dart';
import 'member_filter_dialog.dart';
import 'member_card.dart';
import 'package:flooding_v2/feature/member/view_models/member_view_model.dart';

class RequestMemberListLayout extends StatelessWidget {
  const RequestMemberListLayout({
    super.key,
    required this.searchBar,
    required this.title,
    required this.filterAction,
    required this.emptyIcon,
    required this.memberList,
    required this.isEmpty,
  });

  final Widget searchBar;
  final String title;
  final List<MemberViewModel> memberList;
  final OnFilterSubmit filterAction;
  final Widget emptyIcon;
  final bool isEmpty;

  static const double _bottomPadding = 112;
  static const double _emptyTopPadding = 125;

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
        title,
        style: AppTextStyle.text1.copyWith(color: AppColors.lightMainText),
      ),
      actions: [
        iconButton(
          AppIcon.filter(),
          () => MemberFilterDialog(onSubmit: filterAction).show(context),
        ),
      ],

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.s84),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
          child: searchBar,
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
        physics: !isEmpty
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        slivers: [
          titleBar,
          if (!isEmpty) ...{
            _MemberGridLayout(memberList: memberList),
            const SliverToBoxAdapter(child: SizedBox(height: _bottomPadding)),
          } else ...{
            const SliverToBoxAdapter(child: SizedBox(height: _emptyTopPadding)),
            SliverFillRemaining(child: Center(child: emptyIcon)),
          },
        ],
      ),
    );
  }
}

class _MemberGridLayout extends StatelessWidget {
  const _MemberGridLayout({required this.memberList});

  final List<MemberViewModel> memberList;

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
