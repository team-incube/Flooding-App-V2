import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/widgets/app_card.dart';
import 'package:flooding_v2/feature/school/presentation/widgets/homebase_reservation_container.dart';
import 'package:flutter/material.dart';

import '../models/homebase_reservation_model.dart';

class HomebaseReservationListCard extends StatelessWidget {
  const HomebaseReservationListCard({
    super.key,
    required this.reservations,
    required this.onDelete,
  });

  final List<HomebaseReservationModel> reservations;
  final void Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예약현황',
            style: AppTextStyle.text2.copyWith(color: AppColors.lightMainText),
          ),
          for (final reservation in reservations) ...[
            const SizedBox(height: AppSpacing.s8),
            HomebaseReservationContainer(
              reservation: reservation,
              onDelete: () => onDelete(reservation.id),
            ),
          ],
        ],
      ),
    );
  }
}
