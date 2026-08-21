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
    required this.canManageAll,
    required this.mySchoolNb,
    required this.onDelete,
  });

  final List<HomebaseReservationModel> reservations;

  /// 기숙사 관리자·어드민은 모든 예약을 삭제할 수 있다.
  final bool canManageAll;

  /// 로그인한 사용자의 학번. 신청자 목록에 이 값이 있는 예약에만 삭제 버튼을 노출한다.
  final int? mySchoolNb;

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
          if (reservations.isEmpty) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(
              '현재 모든 테이블 예약이 가능합니다.',
              style: AppTextStyle.text3.copyWith(color: AppColors.lightSub2),
            ),
          ],
          for (final reservation in reservations) ...[
            const SizedBox(height: AppSpacing.s8),
            HomebaseReservationContainer(
              reservation: reservation,
              canDelete:
                  canManageAll ||
                  (mySchoolNb != null &&
                      reservation.students.any(
                        (student) => student.schoolNb == mySchoolNb,
                      )),
              onDelete: () => onDelete(reservation.id),
            ),
          ],
        ],
      ),
    );
  }
}
