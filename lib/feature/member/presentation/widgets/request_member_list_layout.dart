import 'package:flooding_v2/core/enum/role.dart';
import 'package:flooding_v2/core/widgets/primary_action_button.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_selection_bloc.dart';
import 'package:flooding_v2/feature/member/presentation/blocs/member_selection_event.dart';
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
    this.onCheckIn,
    this.onCheckOut,
  });

  final Widget searchBar;
  final String title;
  final Widget emptyIcon;

  /// 미출석 학생을 선택했을 때 체크인 처리하는 콜백(사감 전용 기능).
  ///
  /// 실제 처리는 호출자(feature bloc)가 비동기로 수행하고 완료 시 선택 상태도
  /// 직접 초기화한다 — 이 레이아웃은 선택된 ID만 모아 전달한다. 미지정 시
  /// (예: 안마의자 화면) 하단 액션 버튼은 눌러도 아무 동작을 하지 않는다.
  final void Function(List<int> userIds)? onCheckIn;

  /// 이미 출석한 학생을 선택했을 때 체크아웃(출석 해제) 처리하는 콜백.
  final void Function(List<int> userIds)? onCheckOut;

  static const double _bottomPadding = 112;
  static const double _emptyTopPadding = 125;

  @override
  Widget build(BuildContext context) {
    final isDormManager = context.isManager;

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
                        BlocBuilder<MemberSelectionBloc, MemberSelectionState>(
                          builder: (context, state) {
                            // 선택된 항목이 이미 출석 상태면 체크아웃, 아니면
                            // 체크인 — 선택은 항상 같은 출석 상태끼리만 채워진다.
                            final isCheckOut = state.selectedAttendance == true;
                            final action = isCheckOut ? onCheckOut : onCheckIn;
                            return PrimaryActionButton(
                              label: isCheckOut ? '출석 해제' : '출석 완료',
                              expand: true,
                              enabled: state.checkList.isNotEmpty,
                              onPressed: action == null
                                  ? null
                                  : () => _handleAction(state.checkList, action),
                            );
                          },
                        ),
                  ),
                ),
              ),
            ],
          )
        : body;
  }

  /// 선택된 학생 ID([checkList])로 [action] 을 호출한다. 선택 상태 초기화는
  /// 호출자(feature bloc 의 결과 리스너)가 액션 완료 시점에 직접 수행한다.
  void _handleAction(Set<int> checkList, void Function(List<int> userIds) action) {
    if (checkList.isEmpty) return;
    action(checkList.toList());
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
    final isDormManager = context.isManager;

    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.s8,
      crossAxisSpacing: AppSpacing.s8,
      mainAxisExtent: MemberCard.fixedSize.height,
    );

    if (!isDormManager) {
      return SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: memberList.length,
        itemBuilder: (_, index) =>
            MemberCard(model: memberList[index], number: index + 1),
      );
    }

    final selectionState = context.watch<MemberSelectionBloc>().state;
    final selectedIds = selectionState.checkList;
    final lockedAttendance = selectionState.selectedAttendance;
    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemCount: memberList.length,
      itemBuilder: (_, index) {
        final member = memberList[index];
        return MemberCard.button(
          number: index + 1,
          model: member,
          isSelected: selectedIds.contains(member.id),
          // 이미 선택된 항목과 출석 상태가 다르면(체크인/체크아웃 혼선) 비활성화.
          enabled:
              lockedAttendance == null || lockedAttendance == member.isAttended,
          onSelect: (id, isAttended) => context.read<MemberSelectionBloc>().add(
            MemberSelectionEvent.check(id: id, isAttended: isAttended),
          ),
        );
      },
    );
  }
}
