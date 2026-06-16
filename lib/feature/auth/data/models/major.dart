import 'package:freezed_annotation/freezed_annotation.dart';

enum Major {
  @JsonValue('SW_DEVELOPMENT')
  SW_DEVELOPMENT,
  @JsonValue('SMART_IOT')
  SMART_IOT,
  @JsonValue('AI')
  AI,
}
