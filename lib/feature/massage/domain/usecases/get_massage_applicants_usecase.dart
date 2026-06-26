import '../../../../core/enum/gender.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../member/domain/usecases/get_members_usecase.dart';
import '../../../member/presentation/models/member_model.dart';
import '../../data/models/massage_applicant.dart';
import '../repositories/massage_repository.dart';

/// Flooding 백엔드의 안마의자 신청자 목록을 [MemberModel] 로 변환해 제공한다.
///
/// 기존 [RequestMemberListLayout] UI(목록 그리드)를 그대로 재사용하기 위해
/// 도메인 모델([MassageApplicant])을 프레젠테이션 모델([MemberModel])로 매핑한다.
/// [GetMembersUseCase] 를 구현하므로 [MemberListBloc] 에 그대로 주입할 수 있다.
class GetMassageApplicantsUseCase implements GetMembersUseCase {
  const GetMassageApplicantsUseCase(this._repository);

  final MassageRepository _repository;

  @override
  Future<List<MemberModel>> call() async {
    try {
      final applicants = await _repository.fetchApplicants();
      return applicants.map(_toMember).toList();
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e, s) {
      // 응답 스키마 불일치 등으로 인한 파싱 오류(TypeError 등 Error)도 여기서
      // 사용자 메시지로 정규화한다 — 그대로 흘리면 호출부의 `on Exception`/
      // `on ApiException` 을 빠져나가 로딩 상태가 영영 풀리지 않는다.
      Logger.e('안마의자 신청자 목록 처리 실패', tag: 'MASSAGE', error: e, stackTrace: s);
      throw Exception('목록을 불러오지 못했어요.');
    }
  }

  MemberModel _toMember(MassageApplicant a) => MemberModel(
    name: a.name,
    schoolNb: _schoolNumber(a),
    gender: _gender(a.sex),
  );

  /// 학년·반·번호가 모두 있으면 4자리 학번(예: 2403)으로 합성하고,
  /// 없으면 응답의 `studentNumber` 를 사용한다. (필터가 학번 자릿수에 의존)
  int _schoolNumber(MassageApplicant a) {
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
