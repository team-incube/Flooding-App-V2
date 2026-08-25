import 'package:flooding_v2/core/enum/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
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
    this.showMedal = false,
    this.onCheckIn,
    this.onCheckOut,
  });

  final Widget searchBar;
  final String title;
  final Widget emptyIcon;

  /// 1~3등 메달 아이콘 노출 여부 — 자습처럼 등수 개념이 있는 화면에서만 true.
  final bool showMedal;

  /// 미출석 학생을 선택했을 때 체크인 처리하는 콜백(사감 전용 기능).
  ///
  /// 실제 처리는 호출자(feature bloc)가 비동기로 수행하고 완료 시 선택 상태도
  /// 직접 초기화한다 — 이 레이아웃은 선택된 ID만 모아 전달한다. 미지정 시
  /// (예: 안마의자 화면) 하단 액션 버튼은 눌러도 아무 동작을 하지 않는다.
  final void Function(List<int> userIds)? onCheckIn;

  /// 이미 출석한 학생을 선택했을 때 체크아웃(출석 해제) 처리하는 콜백.
  final void Function(List<int> userIds)? onCheckOut;

  static const double _bottomPadding = 32;
  static const double _emptyTopPadding = 125;

  @override
  Widget build(BuildContext context) {
    final supportsAttendance = onCheckIn != null || onCheckOut != null;
    final canCheckAttendance = context.isManager && supportsAttendance;

    return BlocBuilder<MemberListBloc, MemberListState>(
      builder: (context, state) {
        final memberList =
            state.whenOrNull(
              loaded: (list, _) => list,
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
              _MemberGridLayout(
                memberList: memberList,
                showAttendanceBadge: supportsAttendance,
                showMedal: showMedal,
                onCheckIn: canCheckAttendance ? onCheckIn : null,
                onCheckOut: canCheckAttendance ? onCheckOut : null,
              ),
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
        preferredSize: Size.fromHeight(AppSize.s84),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
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

class _MemberGridLayout extends StatefulWidget {
  const _MemberGridLayout({
    required this.memberList,
    required this.showAttendanceBadge,
    required this.showMedal,
    this.onCheckIn,
    this.onCheckOut,
  });

  final List<MemberModel> memberList;

  /// 출석 완료 배지(체크 아이콘) 노출 여부 — 출석 기능이 있는 화면이면
  /// 역할과 무관하게 true(일반 학생도 출석 현황은 볼 수 있다).
  final bool showAttendanceBadge;
  final bool showMedal;

  final void Function(List<int> userIds)? onCheckIn;
  final void Function(List<int> userIds)? onCheckOut;

  @override
  State<_MemberGridLayout> createState() => _MemberGridLayoutState();
}

class _MemberGridLayoutState extends State<_MemberGridLayout> {
  /// API 호출 중인 사용자 ID 집합. 응답 전까지 카드를 dimming + 탭 차단.
  final Set<int> _pendingIds = {};

  @override
  Widget build(BuildContext context) {
    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.s8,
      crossAxisSpacing: AppSpacing.s8,
      mainAxisExtent: MemberCard.fixedSize.height,
    );

    final hasAction = widget.onCheckIn != null || widget.onCheckOut != null;
    if (!hasAction) {
      return SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: widget.memberList.length,
        itemBuilder: (_, index) => MemberCard(
          model: widget.memberList[index],
          number: index + 1,
          showAttendanceBadge: widget.showAttendanceBadge,
          showMedal: widget.showMedal,
        ),
      );
    }

    // 서버 재조회 완료(fromServer: true) 시 모든 pending 을 해제한다.
    return BlocListener<MemberListBloc, MemberListState>(
      listenWhen: (_, curr) =>
          curr.whenOrNull(loaded: (_, fromServer) => fromServer) ?? false,
      listener: (_, __) {
        if (_pendingIds.isNotEmpty) setState(() => _pendingIds.clear());
      },
      child: SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: widget.memberList.length,
        itemBuilder: (_, index) {
          final member = widget.memberList[index];
          final isPending = _pendingIds.contains(member.id);
          return AbsorbPointer(
            absorbing: isPending,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Opacity(
                  opacity: isPending ? 0.45 : 1.0,
                  child: MemberCard.button(
                    number: index + 1,
                    model: member,
                    showAttendanceBadge: widget.showAttendanceBadge,
                    showMedal: widget.showMedal,
                    onSelect: (id, isAttended) {
                      setState(() => _pendingIds.add(id));
                      context.read<MemberListBloc>().add(
                        MemberListEvent.toggleAttendance(userId: id),
                      );
                      if (isAttended) {
                        widget.onCheckOut?.call([id]);
                      } else {
                        widget.onCheckIn?.call([id]);
                      }
                    },
                  ),
                ),
                if (isPending)
                  const Positioned.fill(
                    child: Center(child: AppLoadingIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
