import '../../../../core/enum/gender.dart';
import '../../../member/domain/usecases/get_members_usecase.dart';
import '../../../member/presentation/models/member_model.dart';
import '../../data/models/study_applicant.dart';
import '../../domain/study_repository.dart';

/// Flooding 백엔드의 자습 신청자 목록을 [MemberModel] 로 변환해 제공한다.
///
/// 기존 [MemberListBloc] / [RequestMemberListLayout] UI 를 그대로 재사용하기 위해
/// 도메인 모델([StudyApplicant])을 프레젠테이션 모델([MemberModel])로 매핑한다.
class GetStudyApplicantsUseCase implements GetMembersUseCase {
  const GetStudyApplicantsUseCase(this._repository);

  final StudyRepository _repository;

  @override
  Future<List<MemberModel>> call() async {
    try {
      final applicants = await _repository.fetchApplicants();
      return applicants.map(_toMember).toList();
    } on StudyException catch (e) {
      throw Exception(e.message ?? '자습 신청자 목록을 불러오지 못했어요.');
    }
  }

  MemberModel _toMember(StudyApplicant a) => MemberModel(
    name: a.name,
    schoolNb: _schoolNumber(a),
    gender: _gender(a.sex),
  );

  /// 학년·반·번호가 모두 있으면 4자리 학번(예: 2403)으로 합성하고,
  /// 없으면 응답의 `studentNumber` 를 사용한다. (필터가 학번 자릿수에 의존)
  int _schoolNumber(StudyApplicant a) {
    final grade = a.grade;
    final classNumber = a.classNumber;
    final number = a.number;
    if (grade != null && classNumber != null && number != null) {
      return grade * 1000 + classNumber * 100 + number;
    }
    return a.studentNumber;
  }

  /// 백엔드 성별 표기(`MAN`/`WOMAN`)를 앱 [Gender] 로 변환한다.
  /// 값이 없거나 알 수 없으면 [Gender.male] 로 둔다.
  Gender _gender(String? sex) {
    switch (sex?.toUpperCase()) {
      case 'WOMAN':
      case 'FEMALE':
        return Gender.female;
      case 'MAN':
      case 'MALE':
      default:
        return Gender.male;
    }
  }
}
