import * as os from 'node:os';
import * as path from 'node:path';

// appium 서버(uiautomator2 쪽)가 SDK 를 찾으려면 ANDROID_HOME 이 필요하다.
// Windows 기본 설치 경로를 폴백으로 잡는다.
process.env.ANDROID_HOME ??= path.join(
  os.homedir(),
  'AppData',
  'Local',
  'Android',
  'Sdk',
);

// 대상 기기는 ANDROID_UDID 로 바꿀 수 있다. (기본: 첫 에뮬레이터)
const udid = process.env.ANDROID_UDID ?? 'emulator-5554';

// build:app 스크립트(integration_test/appium_test.dart 타깃)로 만든 APK.
// 인증을 우회해 곧장 home 으로 진입하는 빌드다.
const appPath = path.resolve(
  __dirname,
  '../build/app/outputs/flutter-apk/app-dev-debug.apk',
);

export const config: WebdriverIO.Config = {
  runner: 'local',
  tsConfigPath: './tsconfig.json',

  hostname: '127.0.0.1',
  port: 4723,

  specs: ['./test/specs/**/*.ts'],
  maxInstances: 1,

  capabilities: [
    // flutter* 벤더 키는 wdio 표준 타입에 없어 명시적으로 캐스팅한다.
    {
      platformName: 'Android',
      'appium:automationName': 'FlutterIntegration',
      'appium:udid': udid,
      'appium:app': appPath,
      'appium:newCommandTimeout': 240,
      'appium:adbExecTimeout': 80000,
      'appium:flutterServerLaunchTimeout': 60000,
      'appium:flutterElementWaitTimeout': 10000,
    } as WebdriverIO.Capabilities,
  ],

  logLevel: 'info',
  bail: 0,
  waitforTimeout: 10000,
  // 느린 에뮬레이터에서 첫 APK 설치 + flutter server 기동이 오래 걸린다.
  connectionRetryTimeout: 600000,
  connectionRetryCount: 1,

  // appium 서버는 wdio 가 직접 띄우고 종료한다. 서버 로그는 logs/ 에 남긴다.
  services: ['flutter-by', ['appium', { logPath: './logs' }]],

  framework: 'mocha',
  reporters: ['spec'],
  mochaOpts: {
    ui: 'bdd',
    timeout: 300000,
  },
};
