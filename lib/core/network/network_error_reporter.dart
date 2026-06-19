/// 네트워크 오류(연결 실패·타임아웃)를 앱 전역으로 알리는 단일 통로.
///
/// [ErrorInterceptor] 가 네트워크 오류를 만나면 [report] 를 호출하고, 앱은
/// [AuthController] 같은 곳에서 [setListener] 로 핸들러를 등록해 로그인 화면으로
/// 보내는 등의 전역 처리를 한다. core 가 인증·라우팅 구현에 의존하지 않도록
/// 콜백 한 개만 보관한다(앱당 1개).
class NetworkErrorReporter {
  NetworkErrorReporter._();

  static void Function()? _listener;

  /// 전역 네트워크 오류 리스너를 등록한다. null 로 호출하면 해제한다.
  static void setListener(void Function()? listener) => _listener = listener;

  /// 네트워크 오류 발생을 알린다. 등록된 리스너가 없으면 조용히 무시한다.
  static void report() => _listener?.call();
}
