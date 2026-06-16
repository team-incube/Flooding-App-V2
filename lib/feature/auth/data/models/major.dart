import 'package:freezed_annotation/freezed_annotation.dart';

enum Major {
  @JsonValue('SW_DEVELOPMENT')
  swDevelopment,
  @JsonValue('SMART_IOT')
  smartIot,
  @JsonValue('AI')
  ai,
}
