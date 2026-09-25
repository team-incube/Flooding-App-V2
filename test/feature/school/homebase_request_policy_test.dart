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

    test('14:19:59 는 신청 불가', () {
      expect(policy.isOpenAt(at(14, 19, 59)), isFalse);
    });

    test('14:20 정각부터 신청 가능', () {
      expect(policy.isOpenAt(at(14, 20)), isTrue);
    });

    test('17:00 은 신청 가능', () {
      expect(policy.isOpenAt(at(17, 0)), isTrue);
    });
  });
}
