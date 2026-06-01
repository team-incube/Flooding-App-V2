/// 공통 팝업(시트·다이얼로그) 묶음 배럴.
///
/// 새 팝업을 만들 땐 이 파일 하나만 import 하면 셸·버튼·헬퍼가 모두 따라온다.
///
/// ```dart
/// import '../../../../core/widgets/sheet/sheet.dart';
/// ```
///
/// ## 새 팝업 추가 레시피
/// 1. 해당 도메인 `presentation/widgets/`에 `xxx_sheet.dart`를 만든다.
///    (도메인이 없는 범용 팝업이면 이 폴더에 둔다 — 예: [DatePickerSheet].)
/// 2. `AppFormSheet`(헤더 → 본문 → 하단 버튼 골격)를 build 에서 반환한다.
///    헤더가 좌측 제목 형태면 [AppSheetTitle]을 그대로 쓴다.
/// 3. 결과 타입 [T]를 갖는 `static Future<T?> show(BuildContext)`를 만들고
///    내부에서 [showAppFormDialog]로 감싼다. (`Navigator.pop`으로 결과 반환.)
/// 4. 단순 확인(예/아니오)만 필요하면 시트를 새로 만들지 말고
///    [AppConfirmDialog.show]를 바로 호출한다.
library;

export 'app_confirm_dialog.dart';
export 'app_form_sheet.dart';
export 'date_picker_sheet.dart';
export 'sheet_action_buttons.dart';
