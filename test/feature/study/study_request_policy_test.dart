import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/feature/study/domain/repositories/study_request_policy.dart';

void main() {
  const policy = StudyRequestPolicy();

  // 정책은 KST(UTC+9) 기준으로 판정하므로, 기기 시간대와 무관하게 결과가
  // 결정적이도록 KST 벽시계 시각을 UTC 로 환산해 전달한다.
  DateTime at(int hour, int minute, [int second = 0]) =>
      DateTime.utc(2026, 6, 16, hour, minute, second)
          .subtract(const Duration(hours: 9));

  group('StudyRequestPolicy.statusAt', () {
    test('19:59 는 신청 시작 전(beforeOpen)', () {
      expect(policy.statusAt(at(19, 59)), StudyWindowStatus.beforeOpen);
    });

    test('20:00 정각부터 신청 가능(open)', () {
      expect(policy.statusAt(at(20, 0)), StudyWindowStatus.open);
    });

    test('20:59 까지 신청 가능(open)', () {
      expect(policy.statusAt(at(20, 59)), StudyWindowStatus.open);
    });

    test('20:59:59 도 아직 open (초는 무시)', () {
      expect(policy.statusAt(at(20, 59, 59)), StudyWindowStatus.open);
    });

    test('21:00 정각이 되면 마감(closed)', () {
      expect(policy.statusAt(at(21, 0)), StudyWindowStatus.closed);
    });

    test('21:01 은 마감(closed)', () {
      expect(policy.statusAt(at(21, 1)), StudyWindowStatus.closed);
    });

    test('낮 시간(12:00)은 신청 시작 전', () {
      expect(policy.statusAt(at(12, 0)), StudyWindowStatus.beforeOpen);
    });
  });

  group('StudyRequestPolicy.isOpenAt', () {
    test('open 시간대에만 true', () {
      expect(policy.isOpenAt(at(20, 30)), isTrue);
      expect(policy.isOpenAt(at(19, 59)), isFalse);
      expect(policy.isOpenAt(at(21, 0)), isFalse);
    });
  });

  group('StudyRequestPolicy KST 환산', () {
    test('기기 시간대와 무관하게 KST 로 판정한다', () {
      // 11:00 UTC == 20:00 KST → open.
      expect(
        policy.statusAt(DateTime.utc(2026, 6, 16, 11, 0)),
        StudyWindowStatus.open,
      );
      // 동일 순간을 +9 오프셋 로컬로 표현해도 같은 결과여야 한다.
      final kstLocal = DateTime.utc(
        2026,
        6,
        16,
        11,
        0,
      ).toLocal();
      expect(policy.statusAt(kstLocal), StudyWindowStatus.open);
      // 09:00 UTC == 18:00 KST → beforeOpen.
      expect(
        policy.statusAt(DateTime.utc(2026, 6, 16, 9, 0)),
        StudyWindowStatus.beforeOpen,
      );
    });
  });
}
