import 'package:flooding_v2/core/network/api_exception.dart';
import 'package:flooding_v2/feature/ai/domain/repositories/ai_repository.dart';
import 'package:flooding_v2/feature/ai/presentation/bloc/chat_bloc.dart';
import 'package:flooding_v2/feature/ai/presentation/bloc/chat_event.dart';
import 'package:flooding_v2/feature/ai/presentation/models/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

/// 지정한 응답을 돌려주거나 오류를 던지는 가짜 AI 저장소.
class _FakeAiRepository implements AiRepository {
  _FakeAiRepository({this.reply = '응답', this.error});

  final String reply;
  final Object? error;
  int sendCount = 0;
  String? lastInput;

  @override
  Future<String> sendMessage(String userInput) async {
    sendCount++;
    lastInput = userInput;
    if (error != null) throw error!;
    return reply;
  }

  @override
  Future<List<String>> recommendSongs() async => const [];
}

void main() {
  group('ChatBloc', () {
    test('메시지 전송 성공 시 사용자/AI 말풍선이 순서대로 쌓인다', () async {
      final repo = _FakeAiRepository(reply: '안녕하세요!');
      final bloc = ChatBloc(repository: repo);

      bloc.add(const ChatEvent.messageSent('안녕'));
      await pumpEventQueue();

      expect(repo.sendCount, 1);
      expect(repo.lastInput, '안녕');
      expect(bloc.state.messages, hasLength(2));
      expect(bloc.state.messages[0].role, ChatRole.user);
      expect(bloc.state.messages[0].text, '안녕');
      expect(bloc.state.messages[1].role, ChatRole.ai);
      expect(bloc.state.messages[1].text, '안녕하세요!');
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNull);
      await bloc.close();
    });

    test('입력 앞뒤 공백을 제거해 전송하고, 빈 입력은 무시한다', () async {
      final repo = _FakeAiRepository();
      final bloc = ChatBloc(repository: repo);

      bloc.add(const ChatEvent.messageSent('   '));
      await pumpEventQueue();
      expect(repo.sendCount, 0);
      expect(bloc.state.messages, isEmpty);

      bloc.add(const ChatEvent.messageSent('  질문  '));
      await pumpEventQueue();
      expect(repo.lastInput, '질문');
      expect(bloc.state.messages.first.text, '질문');
      await bloc.close();
    });

    test('전송 실패 시 대화는 유지하고 error 로 사유를 알린다', () async {
      final repo = _FakeAiRepository(
        error: const ApiException.message('AI 챗봇 서버가 응답하지 않아요.'),
      );
      final bloc = ChatBloc(repository: repo);

      bloc.add(const ChatEvent.messageSent('안녕'));
      await pumpEventQueue();

      // 사용자 말풍선은 남고 AI 응답은 추가되지 않는다.
      expect(bloc.state.messages, hasLength(1));
      expect(bloc.state.messages.first.role, ChatRole.user);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error?.message, 'AI 챗봇 서버가 응답하지 않아요.');
      await bloc.close();
    });

    test('ApiException 이 아닌 오류에도 로딩을 풀고 일반 메시지를 안내한다', () async {
      final repo = _FakeAiRepository(error: StateError('boom'));
      final bloc = ChatBloc(repository: repo);

      bloc.add(const ChatEvent.messageSent('안녕'));
      await pumpEventQueue();

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error?.message, '응답을 받지 못했어요.');
      await bloc.close();
    });
  });
}
