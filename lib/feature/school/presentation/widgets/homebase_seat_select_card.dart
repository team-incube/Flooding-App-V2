import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/widgets/app_card.dart';
import 'package:flooding_v2/core/widgets/card_header.dart';
import 'package:flooding_v2/core/widgets/selectable_chip.dart';
import 'package:flooding_v2/feature/auth/data/models/me.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_bloc.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 홈베이스 좌석(층·교시) 선택 카드. 층은 단일 선택, 교시는 다중 선택으로 구현하였습니다.
class HomeBaseSeatSelectCard extends StatefulWidget {
  const HomeBaseSeatSelectCard({super.key, this.onSelectionChanged});

  /// 층/교시 선택이 바뀔 때마다 호출된다 — 예약현황 목록 필터링에 쓰인다.
  final void Function(int? floor, Set<int> periods)? onSelectionChanged;

  @override
  State<HomeBaseSeatSelectCard> createState() =>
      _HomeBaseSeatSelectCardState();
}

class _HomeBaseSeatSelectCardState extends State<HomeBaseSeatSelectCard> {
  static const List<int> _floors = [2, 3, 4];
  static const List<int> _periods = [8, 9, 10, 11];

  int? _floor;
  final Set<int> _selectedPeriods = {};

  // 학년별 배정 층(3학년→2층, 2학년→3층, 1학년→4층) — 처음 한 번만 자동 선택하고,
  // 이후 사용자가 직접 누르면 그것이 보이도록 한다.
  bool _hasAutoSelectedFloor = false;

  @override
  void initState() {
    super.initState();
    // MeBloc 이 이미 loaded 상태로 들어와 있을 수도 있으므로(BlocListener 는
    // 이후의 상태 "변화"에만 반응한다) 첫 프레임 뒤에 현재 상태도 한 번 확인한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MeBloc>().state.whenOrNull(loaded: _applyDefaultFloor);
    });
  }

  void _notifySelectionChanged() {
    widget.onSelectionChanged?.call(_floor, _selectedPeriods);
  }

  void _applyDefaultFloor(Me me) {
    if (_hasAutoSelectedFloor) return;
    setState(() {
      _floor = 5 - me.grade;
      _hasAutoSelectedFloor = true;
    });
    _notifySelectionChanged();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MeBloc, MeState>(
      listener: (context, state) =>
          state.whenOrNull(loaded: _applyDefaultFloor),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(icon: AppIcon.home, title: '홈베이스'),
            const SizedBox(height: AppSpacing.s16),
            _SelectGroup(
              label: '층',
              children: [
                for (final floor in _floors)
                  SelectableChip(
                    label: '$floor',
                    selected: _floor == floor,
                    onTap: () => setState(() {
                      _floor = _floor == floor ? null : floor;
                      _notifySelectionChanged();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            _SelectGroup(
              label: '교시',
              children: [
                for (final period in _periods)
                  SelectableChip(
                    label: '$period',
                    selected: _selectedPeriods.contains(period),
                    onTap: () => setState(() {
                      if (!_selectedPeriods.remove(period)) {
                        _selectedPeriods.add(period);
                      }
                      _notifySelectionChanged();
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 라벨 + 칩 묶음(가로 나열) 한 그룹.
class _SelectGroup extends StatelessWidget {
  const _SelectGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.text3.copyWith(color: AppColors.lightMainText),
        ),
        const SizedBox(height: AppSpacing.s8),
        Row(
          children: [
            for (final child in children) ...[
              child,
              if (child != children.last) const SizedBox(width: AppSpacing.s8),
            ],
          ],
        ),
      ],
    );
  }
}
