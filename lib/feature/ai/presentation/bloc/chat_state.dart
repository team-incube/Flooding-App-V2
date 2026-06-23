import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/chat_message.dart';

part 'chat_state.freezed.dart';

/// 응답 실패 1회 안내 — 호출자가 SnackBar 등으로 노출한다.
///
/// 매번 새 인스턴스로 생성해 동일 메시지라도 상태 변화를 구분할 수 있게 한다
/// (BlocListener 가 중복 안내를 거르도록).
class ChatError {
  ChatError(this.message);

  final String message;
}

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
    @Default(false) bool isLoading,

    /// 직전 전송 실패 사유(1회성 안내용). 성공/전송 시작 시 null 로 비운다.
    ChatError? error,
  }) = _ChatState;
}
