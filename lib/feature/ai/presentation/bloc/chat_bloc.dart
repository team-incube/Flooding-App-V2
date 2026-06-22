import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/ai_repository.dart';
import '../models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// AI 챗봇 대화 상태를 관리하는 Bloc.
///
/// 사용자가 메시지를 보내면 [AiRepository] 로 서버에 전달하고, 응답을 받아
/// 말풍선 목록에 추가한다. 실패 시 기존 대화는 유지한 채 [ChatState.error] 로
/// 1회 안내한다.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required AiRepository repository})
    : _repository = repository,
      super(const ChatState()) {
    on<ChatEvent>((event, emit) async {
      await event.when(messageSent: (text) => _onMessageSent(text, emit));
    });
  }

  final AiRepository _repository;

  Future<void> _onMessageSent(String text, Emitter<ChatState> emit) async {
    final trimmed = text.trim();
    // 빈 입력이거나 이미 응답 대기 중이면 무시한다(중복 전송 방지).
    if (trimmed.isEmpty || state.isLoading) return;

    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.user, text: trimmed),
        ],
        // 응답이 올 때까지 로딩 인디케이터를 띄운다.
        isLoading: true,
        error: null,
      ),
    );

    try {
      final reply = await _repository.sendMessage(trimmed);
      // 응답을 기다리는 사이 화면을 벗어나 bloc 이 닫혔으면 emit 하지 않는다.
      if (isClosed) return;
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            ChatMessage(role: ChatRole.ai, text: reply),
          ],
          isLoading: false,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: ChatError(e.message)));
    } catch (e, s) {
      // 파싱 오류 등 ApiException 이 아닌 실패에도 로딩을 풀어준다.
      Logger.e('AI 챗봇 응답 실패', tag: 'AI', error: e, stackTrace: s);
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          error: ChatError('응답을 받지 못했어요.'),
        ),
      );
    }
  }
}
