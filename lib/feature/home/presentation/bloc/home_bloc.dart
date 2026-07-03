import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/bloc/me_bloc.dart';
import '../../../auth/presentation/bloc/me_state.dart';
import '../../domain/usecases/get_next_period_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

/// 홈 화면 시간표 카드(다음 교시) 상태를 관리한다.
///
/// [meBloc] 이 내 정보(학년/반)를 불러오는 시점과 무관하게 동작하도록,
/// 생성 시점 상태를 한 번 확인하고 이후 상태 변화도 계속 구독해 로드되는
/// 즉시(또는 재로그인으로 바뀔 때마다) 시간표를 (재)조회한다.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetNextPeriodUseCase getNextPeriod, required MeBloc meBloc})
    : _getNextPeriod = getNextPeriod,
      super(const HomeState()) {
    on<HomeEvent>((event, emit) async {
      await event.when<FutureOr<void>>(
        scheduleRequested: (grade, classNumber) =>
            _onScheduleRequested(emit, grade, classNumber),
      );
    });

    _requestFor(meBloc.state);
    _meSubscription = meBloc.stream.listen(_requestFor);
  }

  final GetNextPeriodUseCase _getNextPeriod;
  late final StreamSubscription<MeState> _meSubscription;

  void _requestFor(MeState meState) {
    final me = meState.whenOrNull(loaded: (me) => me);
    if (me == null) return;
    add(HomeEvent.scheduleRequested(grade: me.grade, classNumber: me.classNumber));
  }

  Future<void> _onScheduleRequested(
    Emitter<HomeState> emit,
    int grade,
    int classNumber,
  ) async {
    emit(state.copyWith(scheduleStatus: ScheduleStatus.loading));
    try {
      final result = await _getNextPeriod(grade: grade, classNumber: classNumber);
      emit(
        state.copyWith(
          scheduleStatus: ScheduleStatus.loaded,
          period: result.period,
          periodStatus: result.status,
          scheduleError: null,
        ),
      );
    } catch (e, s) {
      Logger.e('시간표 조회 실패', tag: 'HOME', error: e, stackTrace: s);
      emit(
        state.copyWith(
          scheduleStatus: ScheduleStatus.error,
          scheduleError: _messageOf(e),
        ),
      );
    }
  }

  String _messageOf(Object e) {
    if (e is ApiException) return e.message;
    final raw = e.toString();
    final stripped = raw.startsWith('Exception: ')
        ? raw.substring('Exception: '.length)
        : raw;
    if (e is! Exception || stripped.isEmpty) return '시간표를 불러오지 못했어요.';
    return stripped;
  }

  @override
  Future<void> close() {
    _meSubscription.cancel();
    return super.close();
  }
}
