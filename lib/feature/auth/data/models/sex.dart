import 'package:freezed_annotation/freezed_annotation.dart';

enum Sex {
  @JsonValue('MAN')
  man,
  @JsonValue('WOMAN')
  woman,
}
