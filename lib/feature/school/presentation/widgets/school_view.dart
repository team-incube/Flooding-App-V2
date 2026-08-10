import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/feature/school/presentation/widgets/homebase_reservation_List_card.dart';
import 'package:flutter/material.dart';

import 'homebase_seat_select_card.dart';
import '../models/homebase_reservation_model.dart';

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
    return SingleChildScrollView(
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
    );
  }
}
