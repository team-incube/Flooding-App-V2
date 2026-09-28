import 'package:flooding_v2/feature/school/domain/homebase_request_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = HomebaseRequestPolicy();

  // 정책은 KST(UTC+9) 기준으로 판정하므로, 기기 시간대와 무관하게 결과가
  // 결정적이도록 KST 벽시계 시각을 UTC 로 환산해 전달한다.
  DateTime at(int hour, int minute, [int second = 0]) =>
      DateTime.utc(2026, 6, 16, hour, minute, second)
          .subtract(const Duration(hours: 9));

  group('HomebaseRequestPolicy.isOpenAt', () {
    test('12:00 은 신청 불가', () {
      expect(policy.isOpenAt(at(12, 0)), isFalse);
    });

    test('13:29:59 는 신청 불가', () {
      expect(policy.isOpenAt(at(13, 29, 59)), isFalse);
    });

    test('13:30 정각부터 신청 가능', () {
      expect(policy.isOpenAt(at(13, 30)), isTrue);
    });

    test('17:00 은 신청 가능', () {
      expect(policy.isOpenAt(at(17, 0)), isTrue);
    });
  });

  group('HomebaseRequestPolicy.untilOpen', () {
    test('13:00 이면 30분 남음', () {
      expect(policy.untilOpen(at(13, 0)), const Duration(minutes: 30));
    });

    test('13:29:30 이면 30초 남음', () {
      expect(policy.untilOpen(at(13, 29, 30)), const Duration(seconds: 30));
    });

    test('13:30 이후에는 null', () {
      expect(policy.untilOpen(at(13, 30)), isNull);
      expect(policy.untilOpen(at(18, 0)), isNull);
    });
  });
}
