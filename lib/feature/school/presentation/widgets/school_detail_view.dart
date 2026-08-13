import 'dart:async';

import 'package:flooding_v2/core/constants/app_radius.dart';
import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/widgets/counted_text_field.dart';
import 'package:flooding_v2/core/widgets/primary_action_button.dart';
import 'package:flooding_v2/core/widgets/search_text_field.dart';
import 'package:flooding_v2/feature/auth/data/models/search_user.dart';
import 'package:flooding_v2/feature/auth/data/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'homebase_seat_select_card.dart';
import 'selected_student_chip.dart';

class SchoolDetailView extends StatefulWidget {
  const SchoolDetailView({super.key});

  @override
  State<SchoolDetailView> createState() => _SchoolDetailViewState();
}

class _SchoolDetailViewState extends State<SchoolDetailView> {
  static const _debounceDuration = Duration(milliseconds: 300);
  static final _digitsOnly = RegExp(r'^\d+$');

  // 검색 결과는 최대 5줄만 보이고 나머지는 스크롤된다.
  static const int _visibleResultCount = 5;
  static const double _resultRowHeight = 54;
  static const double _resultDividerHeight = 24;
  static const double _resultListMaxHeight =
      _resultRowHeight * _visibleResultCount +
      _resultDividerHeight * (_visibleResultCount - 1);

  static const int _reasonMaxLength = 30;

  final _studentSearchController = TextEditingController();
  final _reasonController = TextEditingController();
  final List<SearchUser> _selectedStudents = [];

  Timer? _debounce;
  List<SearchUser> _searchResults = [];

  // 검색 응답이 요청 순서와 다르게 도착해도(레이스 컨디션) 가장 최근에 보낸
  // 요청의 결과만 반영하도록 매 요청마다 증가시켜 비교한다.
  int _searchRequestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _studentSearchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    // 검색어가 없으면 아예 호출하지 않는다 — 입력한 조건에 맞는 결과만 보여준다.
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final requestId = ++_searchRequestId;
    try {
      final isStudentNumber = _digitsOnly.hasMatch(query);
      final page = await context.read<UserService>().searchUsers(
        name: isStudentNumber ? null : query,
        studentNumber: isStudentNumber ? query : null,
      );
      // 그 사이 새 요청이 나갔다면 이 응답은 이미 낡은 것이니 버린다.
      if (!mounted || requestId != _searchRequestId) return;
      final selectedIds = _selectedStudents.map((s) => s.id).toSet();
      setState(() {
        _searchResults = page.content
            .where((student) => !selectedIds.contains(student.id))
            .toList();
      });
    } on Exception catch (_) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() => _searchResults = []);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('검색에 실패했어요')));
    }
  }

  void _selectStudent(SearchUser student) {
    setState(() {
      _selectedStudents.add(student);
      // 하나 고르면 검색 결과 목록 전체를 닫는다.
      _searchResults = [];
      _studentSearchController.clear();
    });
  }

  void _dismissSearchResults() {
    if (_searchResults.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _searchResults = []);
  }

  void _removeStudent(SearchUser student) {
    setState(() => _selectedStudents.remove(student));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissSearchResults,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: AppIcon.back(),
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  '홈베이스 예약',
                  style: AppTextStyle.text2.copyWith(
                    color: AppColors.lightMainText,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s16),
                  const HomeBaseSeatSelectCard(
                    showTableNumber: true,
                    showCard: false,
                    groupSpacing: AppSpacing.s16,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  SearchTextField(
                    textEditingController: _studentSearchController,
                    hintText: '학생 이름, 학번을 입력해주세요.',
                    onChanged: _onQueryChanged,
                  ),
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s8),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: _resultListMaxHeight,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.s12),
                        border: const Border(
                          top: BorderSide(color: AppColors.lightSub4),
                          left: BorderSide(color: AppColors.lightSub4),
                          right: BorderSide(color: AppColors.lightSub4),
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s16,
                        ),
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: _resultDividerHeight,
                          thickness: 1,
                          color: AppColors.lightSub4,
                        ),
                        itemBuilder: (context, index) {
                          final student = _searchResults[index];
                          return InkWell(
                            onTap: () => _selectStudent(student),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.s16),
                              child: Text(
                                '${student.studentNumber} ${student.name}',
                                style: AppTextStyle.text4.copyWith(
                                  color: AppColors.lightMainText,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  CountedTextField(
                    controller: _reasonController,
                    hintText: '이용 사유를 입력해주세요.',
                    maxLength: _reasonMaxLength,
                  ),
                  if (_selectedStudents.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s16),
                    Wrap(
                      spacing: AppSpacing.s4,
                      runSpacing: AppSpacing.s8,
                      children: [
                        for (final student in _selectedStudents)
                          SelectedStudentChip(
                            student: student,
                            onRemove: () => _removeStudent(student),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          PrimaryActionButton(
            label: '예약하기',
            // TODO: 예약 신청 API 연동 후 제출 동작 연결
            onPressed: () {},
            expand: true,
            verticalPadding: AppSpacing.s16,
            horizontalPadding: AppSpacing.s24,
            borderRadius: AppRadius.s8,
          ),
          const SizedBox(height: AppSpacing.s4),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              '※ 홈베이스 신청시 연속 신청이 가능해요.',
              style: AppTextStyle.text4.copyWith(color: AppColors.lightSub2),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}
