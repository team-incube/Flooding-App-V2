/// 홈베이스 좌석(층·테이블 번호) ↔ 백엔드 `homebaseId` 변환.
///
/// 예약 생성 API(`POST /homebase/{homebaseId}`)는 좌석을 `homebaseId` 로만
/// 받는데, 백엔드에 층·테이블 조합으로 이 ID 를 조회하는 엔드포인트가 없다.
/// 대신 DB 시딩 순서(층 오름차순 × 테이블 오름차순)를 그대로 가정한 고정
/// 공식을 쓰기로 백엔드팀과 확인했다 — 층 2 테이블 1~4 → id 1~4,
/// 층 3 → 5~8, 층 4 → 9~12.
class HomebaseSeat {
  const HomebaseSeat._();

  static const List<int> floors = [2, 3, 4];
  static const List<int> tableNumbers = [1, 2, 3, 4];

  static int toId({required int floor, required int tableNumber}) =>
      (floor - floors.first) * tableNumbers.length + tableNumber;

  static int floorOf(int homebaseId) =>
      floors.first + (homebaseId - 1) ~/ tableNumbers.length;

  static int tableNumberOf(int homebaseId) =>
      ((homebaseId - 1) % tableNumbers.length) + 1;
}
