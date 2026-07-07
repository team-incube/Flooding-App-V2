import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

/// SSE(`text/event-stream`)로 수신한 이벤트 1건 — `event` 이름과 `data` 본문.
class SseMessage {
  const SseMessage({required this.event, required this.data});

  /// `event:` 필드 값(미지정 시 SSE 기본값 `message`).
  final String event;

  /// `data:` 필드 값. 여러 줄이면 `\n` 으로 이어 붙인다.
  final String data;
}

/// [dio] 로 [path] 에 SSE 연결을 열어 이벤트를 스트림으로 흘려보낸다.
///
/// dio 를 [ResponseType.stream] 으로 열고 바이트 스트림을 UTF-8·줄 단위로
/// 풀어 SSE 프레임(빈 줄로 구분)을 파싱한다. `:` 로 시작하는 주석 줄(heartbeat)은
/// 무시한다. 구독이 취소되면 [CancelToken] 으로 HTTP 연결도 함께 끊는다.
///
/// SSE 는 장시간 유지되는 연결이라 수신 타임아웃을 비활성화([Duration.zero])한다 —
/// 기본 [BaseOptions.receiveTimeout] 을 그대로 두면 몇 초 뒤 스트림이 끊긴다.
Stream<SseMessage> connectSse(
  Dio dio,
  String path, {
  Map<String, dynamic>? queryParameters,
}) async* {
  final cancelToken = CancelToken();
  try {
    final response = await dio.get<ResponseBody>(
      path,
      queryParameters: queryParameters,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: Duration.zero,
        headers: const {'Accept': 'text/event-stream'},
      ),
      cancelToken: cancelToken,
    );

    final lines = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    String? eventName;
    final data = StringBuffer();

    await for (final line in lines) {
      // 빈 줄 = 프레임 종료 → 지금까지 모은 event/data 를 방출한다.
      if (line.isEmpty) {
        if (data.isNotEmpty || eventName != null) {
          yield SseMessage(event: eventName ?? 'message', data: data.toString());
        }
        eventName = null;
        data.clear();
        continue;
      }
      // 주석(heartbeat 등)은 건너뛴다.
      if (line.startsWith(':')) continue;

      final colon = line.indexOf(':');
      final field = colon == -1 ? line : line.substring(0, colon);
      var value = colon == -1 ? '' : line.substring(colon + 1);
      // 스펙상 콜론 뒤 선행 공백 한 칸은 제거한다.
      if (value.startsWith(' ')) value = value.substring(1);

      switch (field) {
        case 'event':
          eventName = value;
        case 'data':
          if (data.isNotEmpty) data.write('\n');
          data.write(value);
        // id/retry 등 나머지 필드는 사용하지 않는다.
      }
    }
  } finally {
    // 정상 종료·구독 취소 모두에서 HTTP 연결을 확실히 닫는다.
    cancelToken.cancel();
  }
}
