import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/feature/massage/domain/repositories/massage_request_policy.dart';

void main() {
  const policy = MassageRequestPolicy();

  // 정책은 KST(UTC+9) 기준으로 판정하므로, 기기 시간대와 무관하게 결과가
  // 결정적이도록 KST 벽시계 시각을 UTC 로 환산해 전달한다.
  DateTime at(int hour, int minute, [int second = 0]) =>
      DateTime.utc(2026, 6, 16, hour, minute, second)
          .subtract(const Duration(hours: 9));

  group('MassageRequestPolicy.statusAt', () {
    test('20:19 는 신청 시작 전(beforeOpen)', () {
      expect(policy.statusAt(at(20, 19)), MassageWindowStatus.beforeOpen);
    });

    test('20:20 정각부터 신청 가능(open)', () {
      expect(policy.statusAt(at(20, 20)), MassageWindowStatus.open);
    });

    test('20:59 까지 신청 가능(open)', () {
      expect(policy.statusAt(at(20, 59)), MassageWindowStatus.open);
    });

    test('20:59:59 도 아직 open (초는 무시)', () {
      expect(policy.statusAt(at(20, 59, 59)), MassageWindowStatus.open);
    });

    test('21:00 정각이 되면 마감(closed)', () {
      expect(policy.statusAt(at(21, 0)), MassageWindowStatus.closed);
    });

    test('21:01 은 마감(closed)', () {
      expect(policy.statusAt(at(21, 1)), MassageWindowStatus.closed);
    });

    test('자습 시작 시각(20:00)에는 아직 안마의자 신청 전', () {
      expect(policy.statusAt(at(20, 0)), MassageWindowStatus.beforeOpen);
    });
  });

  group('MassageRequestPolicy.isOpenAt', () {
    test('open 시간대에만 true', () {
      expect(policy.isOpenAt(at(20, 30)), isTrue);
      expect(policy.isOpenAt(at(20, 19)), isFalse);
      expect(policy.isOpenAt(at(21, 0)), isFalse);
    });
  });
}
