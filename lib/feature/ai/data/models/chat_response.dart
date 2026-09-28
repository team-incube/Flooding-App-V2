import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_response.freezed.dart';
part 'chat_response.g.dart';

/// `POST /ai/chat` 응답 래퍼(`CommonApiResponse`).
///
/// 실제 챗봇 답변은 [data]([ChatResponseData])의 `response` 필드다.
@freezed
abstract class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    String? status,
    int? code,
    String? message,
    ChatResponseData? data,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);
}

/// `POST /ai/chat` 응답의 `data` 객체 — AI 챗봇의 답변 텍스트를 담는다.
@freezed
abstract class ChatResponseData with _$ChatResponseData {
  const factory ChatResponseData({String? response}) = _ChatResponseData;

  factory ChatResponseData.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseDataFromJson(json);
}
