import 'package:flooding_v2/core/network/api_exception.dart';
import 'package:flooding_v2/feature/ai/domain/repositories/ai_repository.dart';
import 'package:flooding_v2/feature/ai/presentation/bloc/ai_song_bloc.dart';
import 'package:flooding_v2/feature/ai/presentation/bloc/ai_song_event.dart';
import 'package:flooding_v2/feature/ai/presentation/bloc/ai_song_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// 지정한 링크를 돌려주거나 오류를 던지는 가짜 AI 저장소.
class _FakeAiRepository implements AiRepository {
  _FakeAiRepository({this.links = const [], this.error});

  final List<String> links;
  final Object? error;
  int recommendCount = 0;

  @override
  Future<List<String>> recommendSongs() async {
    recommendCount++;
    if (error != null) throw error!;
    return links;
  }

  @override
  Future<String> sendMessage(String userInput) async => '';
}

void main() {
  group('AiSongBloc', () {
    test('요청 성공 시 loading → loaded 로 링크가 곡으로 변환된다', () async {
      final repo = _FakeAiRepository(
        links: const ['https://youtu.be/abc123', 'https://www.youtube.com/watch?v=xyz789'],
      );
      final bloc = AiSongBloc(repository: repo);

      final states = <AiSongStatus>[];
      bloc.stream.listen((s) => states.add(s.status));

      bloc.add(const AiSongEvent.requested());
      await Future<void>.delayed(Duration.zero);

      expect(states, [AiSongStatus.loading, AiSongStatus.loaded]);
      expect(bloc.state.songs.length, 2);
      expect(bloc.state.songs.first.title, 'https://youtu.be/abc123');
      // 유튜브 URL 이므로 썸네일이 생성된다.
      expect(bloc.state.songs.first.thumbnail, isNotNull);
      await bloc.close();
    });

    test('실패(ApiException) 시 error 상태와 메시지를 담는다', () async {
      final repo = _FakeAiRepository(
        error: const ApiException.message('AI 음악 추천 서버가 응답하지 않아요.'),
      );
      final bloc = AiSongBloc(repository: repo);

      bloc.add(const AiSongEvent.requested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.status, AiSongStatus.error);
      expect(bloc.state.error, 'AI 음악 추천 서버가 응답하지 않아요.');
      await bloc.close();
    });

    test("'다시 시도'는 저장소를 다시 호출하고 선택을 초기화한다", () async {
      final repo = _FakeAiRepository(links: const ['https://youtu.be/abc123']);
      final bloc = AiSongBloc(repository: repo);

      bloc.add(const AiSongEvent.requested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AiSongEvent.songSelected(0));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.selectedIndex, 0);

      bloc.add(const AiSongEvent.requested());
      await Future<void>.delayed(Duration.zero);

      expect(repo.recommendCount, 2);
      expect(bloc.state.selectedIndex, isNull);
      await bloc.close();
    });

    test('같은 곡을 다시 선택하면 해제(토글)된다', () async {
      final repo = _FakeAiRepository(links: const ['https://youtu.be/abc123']);
      final bloc = AiSongBloc(repository: repo);

      bloc.add(const AiSongEvent.requested());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const AiSongEvent.songSelected(0));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.selectedIndex, 0);

      bloc.add(const AiSongEvent.songSelected(0));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.selectedIndex, isNull);
      await bloc.close();
    });
  });
}
