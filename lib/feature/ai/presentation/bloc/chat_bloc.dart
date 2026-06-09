import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';


class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState()) {
    on<ChatEvent>(_onMessageSent);
  }

  void _onMessageSent(ChatEvent event, Emitter<ChatState> emit) {
    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.user, text: text),
        ],
      ),
    );

    // TODO: AI 응답 API 연동 후 받은 답변을 ChatRole.ai 메시지로 추가.
  }
}
