# Flutter Project Template

템플릿을 복사한 뒤 아래 스크립트 한 번만 실행하면 패키지명과 번들 ID를 한꺼번에 바꿀 수 있습니다.

```bash
./scripts/rename_project.sh <dart_package_name> <android_package> "<app_display_name>" [ios_bundle_id]
```

예시:

```bash
./scripts/rename_project.sh my_app com.mycompany.myapp "My App"
```

변경되는 항목:

- `pubspec.yaml` 패키지명
- Dart import 경로
- Android `namespace`, `applicationId`, Kotlin package 경로
- iOS `PRODUCT_BUNDLE_IDENTIFIER`
- 앱 표시 이름(`android:label`, `CFBundleDisplayName`, `CFBundleName`)
- `MaterialApp.title`

실행 후:

```bash
flutter pub get
flutter clean
flutter run
```
