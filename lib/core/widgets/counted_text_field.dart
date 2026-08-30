import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../theme/color/app_colors.dart';
import '../theme/text_style/app_text_style.dart';

class CountedTextField extends StatefulWidget {
  const CountedTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    this.maxLines = 3,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int maxLines;

  @override
  State<CountedTextField> createState() => _CountedTextFieldState();
}

class _CountedTextFieldState extends State<CountedTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          height: 120,
          padding: EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(AppRadius.s8),
            border: Border.all(color: AppColors.lightSub2),
          ),
          child: TextField(
            controller: widget.controller,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            style: AppTextStyle.text4.copyWith(color: AppColors.lightSub2),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              counterText: '',
              hintText: widget.hintText,
              hintStyle: AppTextStyle.text4.copyWith(
                color: AppColors.lightSub2,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.s4),
        Text(
          '${widget.controller.text.length}/${widget.maxLength}',
          style: AppTextStyle.caption2.copyWith(color: AppColors.lightSub2),
        ),
      ],
    );
  }
}
