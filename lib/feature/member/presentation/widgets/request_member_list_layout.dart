import 'package:flooding_v2/core/enum/role.dart';
import 'package:flooding_v2/core/widgets/primary_action_button.dart';
import 'package:flooding_v2/feature/auth/presentation/blocs/user_cubit.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_selection_cubit.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_selection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../blocs/member_list_bloc.dart';
import '../blocs/member_list_event.dart';
import '../blocs/member_list_state.dart';
import '../models/member_model.dart';
import 'member_filter_dialog.dart';
import 'member_card.dart';

class RequestMemberListLayout extends StatelessWidget {
  const RequestMemberListLayout({
    super.key,
    required this.searchBar,
    required this.title,
    required this.emptyIcon,
  });

  final Widget searchBar;
  final String title;
  final Widget emptyIcon;

  static const double _bottomPadding = 112;
  static const double _emptyTopPadding = 125;

  @override
  Widget build(BuildContext context) {
    final isDormManager = context.role == Role.dormitoryManager;

    final body = BlocBuilder<MemberListBloc, MemberListState>(
      builder: (context, state) {
        final memberList =
            state.whenOrNull(
              loaded: (list) => list,
              filtered: (list) => list,
            ) ??
            [];

        return CustomScrollView(
          physics: memberList.isNotEmpty
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          slivers: [
            _TopBar(searchBar: searchBar, title: title),
            if (memberList.isNotEmpty) ...{
              _MemberGridLayout(memberList: memberList),
              const SliverToBoxAdapter(child: SizedBox(height: _bottomPadding)),
            } else ...{
              const SliverToBoxAdapter(
                child: SizedBox(height: _emptyTopPadding),
              ),
              SliverFillRemaining(child: Center(child: emptyIcon)),
            },
          ],
        );
      },
    );

    return isDormManager
        ? Stack(
            children: [
              body,
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  child: SizedBox(
                    height: 47,
                    child:
                        BlocBuilder<MemberSelectionCubit, MemberSelectionState>(
                          builder: (context, state) => PrimaryActionButton(
                            label: '출석 완료',
                            expand: true,
                            enabled: state.selected.isNotEmpty,
                          ),
                        ),
                  ),
                ),
              ),
            ],
          )
        : body;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.searchBar, required this.title});

  final String title;
  final Widget searchBar;

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

    return SliverAppBar(
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
          () => MemberFilterDialog(
            onSubmit: (grade, classNb, gender) {
              context.read<MemberListBloc>().add(
                MemberListEvent.filter(
                  grade: grade,
                  classNb: classNb,
                  gender: gender,
                ),
              );
            },
          ).show(context),
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
  }
}

class _MemberGridLayout extends StatelessWidget {
  const _MemberGridLayout({required this.memberList});

  final List<MemberModel> memberList;

  @override
  Widget build(BuildContext context) {
    final isDormManager = context.role == Role.dormitoryManager;

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.s8,
        crossAxisSpacing: AppSpacing.s8,
        mainAxisExtent: MemberCard.fixedSize.height,
      ),
      itemCount: memberList.length,
      itemBuilder: (_, int index) {
        final member = memberList[index];
        final number = index + 1;

        if (isDormManager) {
          final isSelected = context.select<MemberSelectionCubit, bool>(
            (cubit) => cubit.state.selected.contains(member.schoolNb),
          );
          return MemberCard.button(
            number: number,
            model: member,
            isSelected: isSelected,
            onSelect: context.read<MemberSelectionCubit>().toggle,
          );
        } else {
          return MemberCard(model: member, number: number);
        }
      },
    );
  }
}
