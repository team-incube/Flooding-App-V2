import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/text_style/app_text_style.dart';
import 'sheet_action_buttons.dart';

/// 헤더 + 본문 + 하단 버튼 2개로 구성되는 공통 폼 시트 셸.
///
/// 필터·프로필 사진 등록·날짜 선택처럼 "헤더 → 내용 → 보조/주요 버튼" 골격을
/// 공유하는 팝업의 외형을 담당한다. 도메인 콘텐츠는 [body]로, 상단 영역은
/// [header]로 주입한다. 좌측 제목 형태의 헤더는 [AppSheetTitle]을 쓰면 된다.
///
/// 표시는 [showAppFormDialog]로 감싸 가운데 모달로 띄운다.
class AppFormSheet extends StatelessWidget {
  const AppFormSheet({
    super.key,
    required this.header,
    required this.body,
    required this.confirmLabel,
    required this.onConfirm,
    this.backLabel = '뒤로가기',
    this.onBack,
    this.contentPadding,
  });

  /// 상단 영역(제목 또는 네비게이터 등).
  final Widget header;

  /// 헤더와 버튼 사이의 본문.
  final Widget body;

  /// 주요 버튼 라벨. 예) '적용', '등록'.
  final String confirmLabel;

  /// 주요 버튼 동작. null이면 비활성 처리된다.
  final VoidCallback? onConfirm;

  /// 보조 버튼 라벨.
  final String backLabel;

  /// 보조 버튼 동작. null이면 그냥 닫는다.
  final VoidCallback? onBack;

  /// 헤더·본문 영역의 안쪽 여백(하단 버튼 영역은 제외). 캘린더처럼 더 넓은
  /// 콘텐츠는 좌우 여백을 줄여 넘겨준다.
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(AppRadius.s16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                contentPadding ??
                EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s24,
                  AppSpacing.s24,
                  0,
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                SizedBox(height: AppSpacing.s24),
                body,
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.s24),
            child: SheetActionButtons(
              confirmLabel: confirmLabel,
              onConfirm: onConfirm,
              backLabel: backLabel,
              onBack: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 좌측 제목(+ 우측 보조 액션) 형태의 [AppFormSheet] 헤더.
class AppSheetTitle extends StatelessWidget {
  const AppSheetTitle({super.key, required this.title, this.trailing});

  final String title;

  /// 우상단 보조 액션(예: 초기화). 없으면 제목만 표시된다.
  final Widget? trailing;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyle.title3.copyWith(color: AppColors.lightMainText),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// [AppFormSheet] 계열 팝업을 가운데 모달 다이얼로그로 띄우는 공통 헬퍼.
///
/// 좌우 여백을 동일하게 두고 배경을 투명 처리해, [builder]가 그린 카드가
/// 그대로 떠 보이도록 한다. 결과 타입 [T]는 `Navigator.pop`으로 반환한다.
Future<T?> showAppFormDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: AppColors.lightMainText.withValues(alpha: 0.4),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: builder(context),
    ),
  );
}
