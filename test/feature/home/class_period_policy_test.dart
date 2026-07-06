import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/feature/home/domain/repositories/class_period_policy.dart';

void main() {
  const policy = ClassPeriodPolicy();

  // 정책은 KST(UTC+9) 기준으로 판정하므로, 기기 시간대와 무관하게 결과가
  // 결정적이도록 KST 벽시계 시각을 UTC 로 환산해 전달한다.
  DateTime at(int hour, int minute) =>
      DateTime.utc(2026, 6, 16, hour, minute).subtract(const Duration(hours: 9));

  group('ClassPeriodPolicy.periodNumberAt', () {
    test('등교 전(08:00)은 1교시', () {
      expect(policy.periodNumberAt(at(8, 0)), 1);
    });

    test('1교시 진행 중(09:00)은 1교시', () {
      expect(policy.periodNumberAt(at(9, 0)), 1);
    });

    test('1-2교시 쉬는시간(09:35)은 다음 교시인 2교시', () {
      expect(policy.periodNumberAt(at(9, 35)), 2);
    });

    test('점심시간(13:00)은 다음 교시인 5교시', () {
      expect(policy.periodNumberAt(at(13, 0)), 5);
    });

    test('7교시 진행 중(16:00)은 7교시', () {
      expect(policy.periodNumberAt(at(16, 0)), 7);
    });

    test('7교시 종료 정각(16:20)은 하교 이후로 null', () {
      expect(policy.periodNumberAt(at(16, 20)), isNull);
    });

    test('하교 이후(18:00)는 null', () {
      expect(policy.periodNumberAt(at(18, 0)), isNull);
    });
  });

  group('ClassPeriodPolicy KST 환산', () {
    test('기기 시간대와 무관하게 KST 로 판정한다', () {
      // 00:00 UTC == 09:00 KST → 1교시.
      expect(policy.periodNumberAt(DateTime.utc(2026, 6, 16, 0, 0)), 1);
      final kstLocal = DateTime.utc(2026, 6, 16, 0, 0).toLocal();
      expect(policy.periodNumberAt(kstLocal), 1);
    });
  });
}
