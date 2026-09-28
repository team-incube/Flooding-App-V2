import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_event.freezed.dart';

/// AI 챗봇 화면에서 발생하는 사용자 이벤트.
@freezed
sealed class ChatEvent with _$ChatEvent {
  /// 사용자가 메시지를 전송했다. [ChatBloc] 이 서버 응답까지 처리한다.
  const factory ChatEvent.messageSent(String text) = _ChatMessageSent;
}
