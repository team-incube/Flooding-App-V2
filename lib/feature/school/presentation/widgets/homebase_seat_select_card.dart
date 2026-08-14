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
import 'package:flooding_v2/feature/school/domain/homebase_seat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 홈베이스 좌석(층·교시) 선택 카드. 층은 단일 선택, 교시는 다중 선택으로 구현하였습니다.
class HomeBaseSeatSelectCard extends StatefulWidget {
  const HomeBaseSeatSelectCard({
    super.key,
    this.onSelectionChanged,
    this.showTableNumber = false,
    this.onTableNumberChanged,
    this.showCard = true,
    this.groupSpacing = AppSpacing.s8,
    this.initialFloor,
    this.initialPeriods,
  });

  /// 이전 화면(SchoolView)에서 이미 골라둔 층 — 있으면 학년별 기본값보다 우선한다.
  final int? initialFloor;

  /// 이전 화면(SchoolView)에서 이미 골라둔 교시 — 있으면 학년별 기본값보다 우선한다.
  final Set<int>? initialPeriods;

  /// 층/교시 선택이 바뀔 때마다 호출된다 — 예약현황 목록 필터링에 쓰인다.
  final void Function(int? floor, Set<int> periods)? onSelectionChanged;

  /// 테이블 번호 그룹 노출 여부 — 목록/필터 화면(SchoolView)에서는 false,
  /// 예약 상세 화면(SchoolDetailView)에서는 true로 켠다.
  final bool showTableNumber;

  /// 카드(배경·그림자) + "홈베이스" 헤더로 감쌀지 여부 — 목록/필터 화면에서는
  /// true, 예약 상세 화면에서는 글자·칩만 노출하도록 false로 켠다.
  final bool showCard;

  /// 층/교시/테이블 번호 그룹 사이 세로 간격.
  final double groupSpacing;

  /// 테이블 번호 선택이 바뀔 때마다 호출된다([showTableNumber]가 true일 때만 의미 있다).
  final ValueChanged<int?>? onTableNumberChanged;

  @override
  State<HomeBaseSeatSelectCard> createState() => _HomeBaseSeatSelectCardState();
}

class _HomeBaseSeatSelectCardState extends State<HomeBaseSeatSelectCard> {
  static const List<int> _floors = HomebaseSeat.floors;
  static const List<int> _periods = [8, 9, 10, 11];
  static const List<int> _tableNumbers = HomebaseSeat.tableNumbers;

  // 교시별 신청 마감 시각 — 지나면 해당 교시 칩이 비활성화된다.
  static const Map<int, TimeOfDay> _periodDeadlines = {
    8: TimeOfDay(hour: 16, minute: 40),
    9: TimeOfDay(hour: 17, minute: 40),
    10: TimeOfDay(hour: 19, minute: 30),
    11: TimeOfDay(hour: 20, minute: 30),
  };

  late int? _floor = widget.initialFloor;
  late final Set<int> _selectedPeriods = {...?widget.initialPeriods};
  int? _tableNumber;

  bool _isPeriodClosed(int period) {
    final deadline = _periodDeadlines[period];
    if (deadline == null) return false;
    final now = DateTime.now();
    final deadlineTime = DateTime(
      now.year,
      now.month,
      now.day,
      deadline.hour,
      deadline.minute,
    );
    return now.isAfter(deadlineTime);
  }

  // 학년별 배정 층(3학년→2층, 2학년→3층, 1학년→4층) — 처음 한 번만 자동 선택하고,
  // 이후 사용자가 직접 누르면 그것이 보이도록 한다. 이전 화면에서 이미 층을
  // 넘겨받았다면(initialFloor) 학년 기본값으로 덮어쓰지 않는다.
  late bool _hasAutoSelectedFloor = widget.initialFloor != null;

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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showCard) ...[
          const CardHeader(icon: AppIcon.home, title: '홈베이스'),
          const SizedBox(height: AppSpacing.s16),
        ],
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
        SizedBox(height: widget.groupSpacing),
        _SelectGroup(
          label: '교시',
          children: [
            for (final period in _periods)
              SelectableChip(
                label: '$period',
                selected: _selectedPeriods.contains(period),
                disabled: _isPeriodClosed(period),
                onTap: () => setState(() {
                  if (!_selectedPeriods.remove(period)) {
                    _selectedPeriods.add(period);
                  }
                  _notifySelectionChanged();
                }),
              ),
          ],
        ),
        if (widget.showTableNumber) ...[
          SizedBox(height: widget.groupSpacing),
          _SelectGroup(
            label: '테이블 번호',
            children: [
              for (final table in _tableNumbers)
                SelectableChip(
                  label: '$table',
                  selected: _tableNumber == table,
                  onTap: () => setState(() {
                    _tableNumber = _tableNumber == table ? null : table;
                    widget.onTableNumberChanged?.call(_tableNumber);
                  }),
                ),
            ],
          ),
        ],
      ],
    );

    return BlocListener<MeBloc, MeState>(
      listener: (context, state) =>
          state.whenOrNull(loaded: _applyDefaultFloor),
      child: widget.showCard ? AppCard(child: content) : content,
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
