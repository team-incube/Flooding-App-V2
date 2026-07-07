/// AI 챗봇 도메인 계약.
///
/// 구현체는 백엔드 오류를 `ApiException` 으로 표면화한다.
abstract interface class AiRepository {
  /// 사용자 입력([userInput])을 AI 챗봇 서버로 보내고 응답 텍스트를 반환한다.
  ///
  /// 빈 응답·서버 오류(502 등)·네트워크 실패 시 `ApiException` 을 던진다.
  Future<String> sendMessage(String userInput);

  /// 로그인 사용자의 최근 기상송 신청 내역 기반으로 추천 유튜브 링크를 받는다.
  ///
  /// 서버 오류(502 등)·네트워크 실패 시 `ApiException` 을 던진다.
  Future<List<String>> recommendSongs();
}
