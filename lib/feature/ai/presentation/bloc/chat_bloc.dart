import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState()) {
    on<ChatEvent>((event, emit) {
      event.when(
        messageSent: (text) => _onMessageSent(text, emit),
        messageReceived: (text) => _onMessageReceived(text, emit),
      );
    });
  }

  void _onMessageSent(String text, Emitter<ChatState> emit) {
    if (text.isEmpty) return;

    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.user, text: text),
        ],
        // 응답이 올 때까지 로딩 인디케이터를 띄운다.
        isLoading: true,
      ),
    );
  }

  void _onMessageReceived(String text, Emitter<ChatState> emit) {
    if (text.isEmpty) return;

    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.ai, text: text),
        ],
        isLoading: false,
      ),
    );
  }
}
