import 'package:flooding_v2/core/constants/app_radius.dart';
import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/route/route_path.dart';
import 'package:flooding_v2/core/widgets/primary_action_button.dart';
import 'package:flooding_v2/feature/school/presentation/widgets/homebase_reservation_List_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'homebase_seat_select_card.dart';
import '../models/homebase_reservation_model.dart';
import '../models/school_seat_selection.dart';

class SchoolView extends StatefulWidget {
  const SchoolView({super.key});

  @override
  State<SchoolView> createState() => _SchoolViewState();
}

class _SchoolViewState extends State<SchoolView> {
  // TODO: 서버 예약 목록 연동 전까지 빈 목록으로 둔다.
  final List<HomebaseReservationModel> _reservations = const [];

  int? _floor;
  Set<int> _periods = const {};

  List<HomebaseReservationModel> get _filteredReservations {
    return _reservations.where((reservation) {
      final matchesFloor = _floor == null || reservation.floor == _floor;
      final matchesPeriod =
          _periods.isEmpty || reservation.periods.any(_periods.contains);
      return matchesFloor && matchesPeriod;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HomeBaseSeatSelectCard(
                    onSelectionChanged: (floor, periods) => setState(() {
                      _floor = floor;
                      _periods = periods;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  HomebaseReservationListCard(
                    reservations: _filteredReservations,
                    onDelete: (_) {},
                  ),
                ],
              ),
            ),
          ),
          PrimaryActionButton(
            label: '예약하기',
            onPressed: () => context.push(
              RoutePath.schoolDetail,
              extra: SchoolSeatSelection(floor: _floor, periods: _periods),
            ),
            expand: true,
            verticalPadding: AppSpacing.s16,
            horizontalPadding: AppSpacing.s24,
            borderRadius: AppRadius.s8,
          ),
          const SizedBox(height: AppSpacing.s4),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              '※ 홈베이스 신청시 연속 신청이 가능해요.',
              style: AppTextStyle.text4.copyWith(color: AppColors.lightSub2),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}
