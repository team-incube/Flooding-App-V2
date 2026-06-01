import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/sheet/sheet.dart';

/// 성별 필터 값.
enum Gender {
  male('남자'),
  female('여자');

  const Gender(this.label);

  /// 칩에 표시할 한국어 라벨.
  final String label;
}

/// 기숙사 목록 필터 조건(학년·반·성별). 각 항목은 미선택 시 null이다.
class DormitoryFilter {
  const DormitoryFilter({this.grade, this.classNumber, this.gender});

  final int? grade;
  final int? classNumber;
  final Gender? gender;

  DormitoryFilter copyWith({int? grade, int? classNumber, Gender? gender}) {
    return DormitoryFilter(
      grade: grade ?? this.grade,
      classNumber: classNumber ?? this.classNumber,
      gender: gender ?? this.gender,
    );
  }
}

/// 학년·반·성별을 선택하는 필터 팝업.
///
/// 각 그룹은 단일 선택이며, 같은 칩을 다시 누르면 해제된다. '초기화'로 전체
/// 선택을 비우고, '적용'으로 [DormitoryFilter]를 반환한다.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, this.initial = const DormitoryFilter()});

  /// 시트를 열 때의 초기 선택 값.
  final DormitoryFilter initial;

  /// 필터 팝업을 띄우고 적용된 [DormitoryFilter]를 반환한다.
  /// 뒤로가기·바깥 탭으로 닫으면 null을 반환한다.
  static Future<DormitoryFilter?> show(
    BuildContext context, {
    DormitoryFilter current = const DormitoryFilter(),
  }) {
    return showAppFormDialog<DormitoryFilter>(
      context,
      builder: (_) => FilterSheet(initial: current),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  static const List<int> _grades = [1, 2, 3];
  static const List<int> _classes = [1, 2, 3, 4];

  late int? _grade = widget.initial.grade;
  late int? _classNumber = widget.initial.classNumber;
  late Gender? _gender = widget.initial.gender;

  void _reset() {
    setState(() {
      _grade = null;
      _classNumber = null;
      _gender = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      DormitoryFilter(
        grade: _grade,
        classNumber: _classNumber,
        gender: _gender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSheet(
      header: AppSheetTitle(
        title: '필터',
        trailing: _ResetButton(onTap: _reset),
      ),
      confirmLabel: '적용',
      onConfirm: _apply,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterGroup(
            label: '학년',
            children: [
              for (final g in _grades)
                _FilterChip(
                  label: '$g',
                  selected: _grade == g,
                  onTap: () => setState(() => _grade = _grade == g ? null : g),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          _FilterGroup(
            label: '반',
            children: [
              for (final c in _classes)
                _FilterChip(
                  label: '$c',
                  selected: _classNumber == c,
                  onTap: () => setState(
                    () => _classNumber = _classNumber == c ? null : c,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          _FilterGroup(
            label: '성별',
            children: [
              for (final gender in Gender.values)
                _FilterChip(
                  label: gender.label,
                  selected: _gender == gender,
                  onTap: () => setState(
                    () => _gender = _gender == gender ? null : gender,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 우상단 '초기화' 텍스트 버튼.
class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        '초기화',
        style: AppTextStyle.caption1.copyWith(color: AppColors.lightSub1),
      ),
    );
  }
}

/// 라벨 + 칩 묶음(가로 나열) 한 그룹.
class _FilterGroup extends StatelessWidget {
  const _FilterGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.text2.copyWith(color: AppColors.lightMainText),
        ),
        const SizedBox(height: AppSpacing.s8),
        Row(
          children: [
            for (final child in children) ...[
              child,
              if (child != children.last) const SizedBox(width: AppSpacing.s8),
            ],
          ],
        ),
      ],
    );
  }
}

/// 선택 가능한 필터 칩(미선택: 테두리, 선택: 메인 컬러 채움).
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.lightP1 : Colors.transparent;
    final textColor = selected ? AppColors.lightBgSurface : AppColors.lightSub1;
    final border = selected ? null : Border.all(color: AppColors.lightSub2);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.s8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.s8),
        child: Container(
          decoration: BoxDecoration(
            border: border,
            borderRadius: BorderRadius.circular(AppRadius.s8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: Text(
            label,
            style: AppTextStyle.text3.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
