/// Flooding 백엔드 API 경로의 공통 prefix 상수.
///
/// 여러 기능이 공유하는 도메인 prefix 를 한 곳에서 관리한다.
/// 기능별 세부 경로는 각 datasource 의 `_Endpoints` 에서 이 값을 합성해 쓴다.
class ApiEndpoints {
  ApiEndpoints._();

  /// 기숙사 도메인 공통 prefix — 자습/안마/기상음악/청소구역/벌점 등.
  static const String dormitory = '/dormitory';

  /// 사용자 도메인 공통 prefix — 내 정보/학생 검색 등.
  static const String users = '/users';

  /// 인증 도메인 공통 prefix — 로그인/토큰 재발급.
  static const String auth = '/auth';
}
