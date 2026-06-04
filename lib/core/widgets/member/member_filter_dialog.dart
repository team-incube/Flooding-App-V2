import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../enum/gender.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/text_style/app_text_style.dart';
import '../primary_action_button.dart';

typedef OnTagChange<T> = void Function(T? value);
typedef OnFilterSubmit =
    void Function(int? grade, int? classNb, Gender? gender);

class MemberFilterDialog extends StatefulWidget {
  const MemberFilterDialog({super.key, required this.onSubmit, this.onCancel});

  final OnFilterSubmit onSubmit;
  final VoidCallback? onCancel;

  static const _fixedSize = Size(354, 399);

  void show(BuildContext context) =>
      showDialog(context: context, builder: (context) => this);

  @override
  State<MemberFilterDialog> createState() => _MemberFilterDialogState();
}

class _MemberFilterDialogState extends State<MemberFilterDialog> {
  int? grade;
  int? classNb;
  String? gender;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(
        maxHeight: MemberFilterDialog._fixedSize.height,
        maxWidth: MemberFilterDialog._fixedSize.width,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.s12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('필터', style: AppTextStyle.title3)],
            ),
            const SizedBox(height: AppSpacing.s24),
            _TagLine<int>(
              title: '학년',
              list: List.generate(3, (index) => index + 1),
              onTagChange: (value) {
                grade = value;
              },
            ),
            const SizedBox(height: AppSpacing.s24),
            _TagLine<int>(
              title: '반',
              list: List.generate(4, (index) => index + 1),
              onTagChange: (value) {
                classNb = value;
              },
            ),
            const SizedBox(height: AppSpacing.s24),
            _TagLine<String>(
              title: '성별',
              list: Gender.values.map((e) => e.ko).toList(),
              onTagChange: (value) {
                gender = value;
              },
            ),
            const SizedBox(height: AppSpacing.s24),

            Row(
              children: [
                Expanded(
                  child: PrimaryActionButton(
                    label: '뒤로가기',
                    horizontalPadding: AppSpacing.s32,
                    verticalPadding: AppSpacing.s14,
                    onPressed: widget.onCancel ?? () => context.pop(),
                    expand: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: PrimaryActionButton(
                    label: '적용',
                    horizontalPadding: AppSpacing.s32,
                    verticalPadding: AppSpacing.s14,
                    onPressed: () {
                      context.pop();
                      widget.onSubmit.call(
                        grade,
                        classNb,
                        Gender.values.where((g) => g.ko == gender).firstOrNull,
                      );
                    },
                    expand: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagLine<T> extends StatefulWidget {
  const _TagLine({
    super.key,
    required this.title,
    required this.list,
    required this.onTagChange,
  });

  final String title;
  final List<T> list;
  final OnTagChange<T> onTagChange;

  @override
  State<_TagLine<T>> createState() => _TagLineState<T>();
}

class _TagLineState<T> extends State<_TagLine<T>> {
  T? selectedValue;

  @override
  Widget build(BuildContext context) {
    Widget tag(T value) {
      final radius = BorderRadius.circular(AppRadius.s8);

      final boxDecoration = selectedValue == value
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.lightP1),
              color: AppColors.lightP1,
            )
          : BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.lightSub2),
            );

      final textStyle = AppTextStyle.text3.copyWith(
        color: selectedValue == value
            ? AppColors.lightBgSurface
            : AppColors.lightSub1,
      );

      return InkWell(
        onTap: () {
          final newValue = selectedValue == value ? null : value;
          setState(() {
            selectedValue = newValue;
          });
          widget.onTagChange.call(newValue);
        },
        borderRadius: radius,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          decoration: boxDecoration,
          child: Text('$value', style: textStyle),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: AppTextStyle.text2),
        const SizedBox(height: AppSpacing.s8),
        SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: AppSpacing.s8,
            children: widget.list.map((e) => tag(e)).toList(),
          ),
        ),
      ],
    );
  }
}
