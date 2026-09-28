import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_request.freezed.dart';
part 'chat_request.g.dart';

/// `POST /ai/chat` 요청 본문.
///
/// 서버 스키마가 snake_case(`user_input`)이므로 직렬화 키를 맞춘다.
@freezed
abstract class ChatRequest with _$ChatRequest {
  const factory ChatRequest({
    @JsonKey(name: 'user_input') required String userInput,
  }) = _ChatRequest;

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);
}
