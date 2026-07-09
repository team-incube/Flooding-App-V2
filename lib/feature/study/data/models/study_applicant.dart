import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_applicant.freezed.dart';
part 'study_applicant.g.dart';

/// 자습을 신청한 학생 1명의 정보.
///
/// `GET /dormitory/studies` 응답의 `data` 항목.
///
/// 주의: 현재 Swagger 문서에 응답 `data` 스키마가 정의돼 있지 않아,
/// 공통 사용자 응답(`SearchUsersResponse`)을 기준으로 모델링했다.
/// 서버가 보장하는 필드(`ApplicantInfo`: id/name/studentNumber)만 required 로 두고,
/// 학년·반·번호 등 부가 필드는 nullable 로 둔다. 실제 응답 확인 후 보정한다.
@freezed
abstract class StudyApplicant with _$StudyApplicant {
  const factory StudyApplicant({
    /// 서버 응답에서는 `userId` 키로 내려온다.
    @JsonKey(name: 'userId') required int id,
    required String name,
    required int studentNumber,
    int? grade,
    int? classNumber,
    int? number,

    /// 성별 — 백엔드 표기: `MAN` / `WOMAN`.
    String? sex,

    /// 자습 금지 여부.
    bool? isBanned,

    /// 자습 체크인(출석) 완료 여부 — 서버 응답 키: `isChecked`.
    @JsonKey(name: 'isChecked') bool? isAttended,
    String? profileImageUrl,
  }) = _StudyApplicant;

  factory StudyApplicant.fromJson(Map<String, dynamic> json) =>
      _$StudyApplicantFromJson(json);
}
