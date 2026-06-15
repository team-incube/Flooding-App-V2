/// 채팅 메시지의 발신 주체.
enum ChatRole {
  /// 사용자가 보낸 메시지.
  user,

  /// AI 챗봇이 보낸 메시지.
  ai,
}

/// AI 챗봇 대화의 메시지 한 개.
class ChatMessage {
  const ChatMessage({required this.role, required this.text});

  final ChatRole role;
  final String text;

  bool get isUser => role == ChatRole.user;
}
