import 'package:flooding_v2/feature/home/data/models/period_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_data.freezed.dart';

part 'timetable_data.g.dart';

/// `GET /v2/neis/timetables` 응답의 실제 페이로드(`data` 필드).
@freezed
abstract class TimetableData with _$TimetableData {
  const factory TimetableData({
    required DateTime date,
    required int grade,
    required int classNumber,
    required List<PeriodData> periods,
  }) = _TimetableData;

  factory TimetableData.fromJson(Map<String, dynamic> json) =>
      _$TimetableDataFromJson(json);
}
