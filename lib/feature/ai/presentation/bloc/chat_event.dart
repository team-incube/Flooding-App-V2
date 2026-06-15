import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_event.freezed.dart';

/// AI 챗봇 화면에서 발생하는 사용자 이벤트.
@freezed
sealed class ChatEvent with _$ChatEvent {
  const factory ChatEvent.messageSent(String text) = _ChatMessageSent;
  const factory ChatEvent.messageReceived(String text) = _ChatMessageReceived;
}
