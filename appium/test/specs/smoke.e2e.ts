import { browser, expect } from '@wdio/globals';

/**
 * 부팅 스모크 테스트.
 *
 * appium_test.dart 엔트리포인트는 가짜 토큰 저장소로 인증을 우회하므로
 * 앱은 로그인 없이 곧장 home 으로 진입해야 한다.
 */
describe('Flooding 앱 스모크', () => {
  it('부팅하면 홈 화면(시간표 카드)이 렌더링된다', async () => {
    const timetableHeader = await browser.flutterByText$('시간표');
    await expect(timetableHeader).toBeDisplayed();
  });
});
