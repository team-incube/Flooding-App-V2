import 'package:freezed_annotation/freezed_annotation.dart';

part 'period_data.freezed.dart';

part 'period_data.g.dart';

@freezed
abstract class PeriodData with _$PeriodData {
  factory PeriodData({
    required int period,
    required String subject,
    required String? teacher,
    required int? classroom,
  }) = _PeriodData;

  factory PeriodData.fromJson(Map<String, dynamic> json) =>
      _$PeriodDataFromJson(json);
}

/*
{
"period": int,
"subject": string,
"teacher": string,
"classroom": int
}*/
