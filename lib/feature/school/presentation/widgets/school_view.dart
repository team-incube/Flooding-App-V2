import 'package:flooding_v2/core/constants/app_radius.dart';
import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/enum/role.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/route/route_path.dart';
import 'package:flooding_v2/core/widgets/app_loading_indicator.dart';
import 'package:flooding_v2/core/widgets/primary_action_button.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_bloc.dart';
import 'package:flooding_v2/feature/auth/presentation/bloc/me_state.dart';
import 'package:flooding_v2/feature/school/presentation/widgets/homebase_reservation_List_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'homebase_seat_select_card.dart';
import '../bloc/school_bloc.dart';
import '../bloc/school_event.dart';
import '../bloc/school_state.dart';
import '../models/homebase_reservation_model.dart';
import '../models/school_seat_selection.dart';

class SchoolView extends StatefulWidget {
  const SchoolView({super.key});

  @override
  State<SchoolView> createState() => _SchoolViewState();
}

class _SchoolViewState extends State<SchoolView> {
  int? _floor;
  Set<int> _periods = const {};

  @override
  void initState() {
    super.initState();
    // 이미 조회된 적이 있으면(다른 탭에서 되돌아온 경우) 인디케이터 없이
    // 값만 갱신하는 재조회로, 처음 진입이면 인디케이터를 띄우는 조회로 요청한다.
    final bloc = context.read<SchoolBloc>();
    bloc.add(
      SchoolEvent.reservationsRequested(
        refresh: bloc.state.listStatus == SchoolListStatus.loaded,
      ),
    );
  }

  List<HomebaseReservationModel> _filter(
    List<HomebaseReservationModel> reservations,
  ) {
    return reservations.where((reservation) {
      final matchesFloor = _floor == null || reservation.floor == _floor;
      final matchesPeriod =
          _periods.isEmpty || reservation.periods.any(_periods.contains);
      return matchesFloor && matchesPeriod;
    }).toList();
  }

  void _showSnack(String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // 기숙사 관리자·어드민은 모든 예약을, 일반 사용자는 본인 학번이 신청자
    // 목록에 있는 예약만 삭제할 수 있다.
    final mySchoolNb = context.select<MeBloc, int?>(
      (bloc) => bloc.state.maybeWhen(loaded: (me) => me.studentNumber, orElse: () => null),
    );
    final canManageAll = context.isManager;

    return BlocListener<SchoolBloc, SchoolState>(
      listenWhen: (prev, curr) =>
          curr.result != null && !identical(prev.result, curr.result),
      listener: (context, state) => _showSnack(state.result?.message),
      child: BlocBuilder<SchoolBloc, SchoolState>(
        builder: (context, state) {
          final isLoading =
              state.listStatus == SchoolListStatus.initial ||
              state.listStatus == SchoolListStatus.loading;
          final filtered = _filter(state.reservations);

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
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.s24,
                            ),
                            child: AppLoadingIndicator(),
                          )
                        else
                          HomebaseReservationListCard(
                            reservations: filtered,
                            canManageAll: canManageAll,
                            mySchoolNb: mySchoolNb,
                            onDelete: (id) => context.read<SchoolBloc>().add(
                              SchoolEvent.reservationDeleted(reservationId: id),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                PrimaryActionButton(
                  label: '예약하기',
                  onPressed: () => context.push(
                    RoutePath.schoolDetail,
                    extra: SchoolSeatSelection(
                      floor: _floor,
                      periods: _periods,
                    ),
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
                    style: AppTextStyle.text4.copyWith(
                      color: AppColors.lightSub2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
              ],
            ),
          );
        },
      ),
    );
  }
}
