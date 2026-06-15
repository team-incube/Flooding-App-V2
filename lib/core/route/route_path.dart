/// 앱 라우트 경로 상수.
///
/// 문자열 리터럴 산재를 막고 redirect/네비게이션에서 동일 값을 참조하도록 모은다.
abstract final class RoutePath {
  const RoutePath._();

  /// 홈(초기 진입점). 미인증 시 redirect 가 [login] 으로 보낸다.
  static const String home = '/home';
  static const String dormitory = '/dormitory';
  static const String requestStudy = '/request_study';
  static const String requestMassage = '/request_massage';
  static const songRequestDetail = '/song_request_detail';

  /// AI 챗봇 대화 화면.
  static const String aiChat = '/ai_chat';

  /// DataGSM OAuth 로그인 화면.
  static const String login = '/login';
}
