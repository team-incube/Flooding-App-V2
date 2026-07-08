import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/widgets/search_text_field.dart';
import '../../../member/presentation/blocs/member_list_bloc.dart';
import '../../../member/presentation/blocs/member_list_state.dart';
import '../../../member/presentation/widgets/no_member_icon.dart';
import '../../../member/presentation/widgets/request_member_list_layout.dart';

/// 안마의자 신청자 목록(자세히 보기) 화면.
///
/// 그리드·빈 상태·로딩을 모두 [MemberListBloc] 하나로 구동한다 — 라우트에서
/// 이 bloc 이 진입 시 1회 로드(`MemberListEvent.load`)하므로 화면에서 별도 조회를
/// 트리거하지 않는다(중복 호출 방지). 신청자 수·신청/취소 버튼은 홈·기숙사의
/// 카운트 카드(`MassageBloc`)가 담당한다.
class MassageRequestView extends StatefulWidget {
  const MassageRequestView({super.key});

  @override
  State<MassageRequestView> createState() => _MassageRequestViewState();
}

class _MassageRequestViewState extends State<MassageRequestView> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberListBloc, MemberListState>(
      builder: (context, state) {
        return RequestMemberListLayout(
          title: '안마의자 신청',
          searchBar: SearchTextField(
            textEditingController: searchController,
            hintText: '학생 이름, 학번을 입력해주세요',
          ),
          emptyIcon: state.when(
            initial: _loading,
            loading: _loading,
            // 필터 결과만 비어 있는 경우.
            filtered: (_) => NoMemberIcon(
              icon: AppIcon.chair(size: AppSize.s100),
              title: '조건에 맞는 학생이 없습니다.',
              subTitle: '필터 설정을 확인해 주세요.',
            ),
            loaded: (_, __) => _emptyApplicants(),
            error: (_) => _emptyApplicants(),
          ),
        );
      },
    );
  }

  Widget _loading() =>
      const Center(child: CircularProgressIndicator());

  Widget _emptyApplicants() => NoMemberIcon(
    icon: AppIcon.chair(size: AppSize.s100),
    title: '안마의자를 신청한 인원이 없습니다.',
    subTitle: '안마 의자 신청 시간은 20:20 ~ 21:00에 신청이 가능해요',
    tipTitle: '※ 여학생의 경우 여자 사감선생님께 별도로 신청해주시기 바랍니다.',
  );
}
