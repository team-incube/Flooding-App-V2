import 'package:flutter_test/flutter_test.dart';
import 'package:flooding_v2/core/enum/gender.dart';
import 'package:flooding_v2/feature/study/data/models/study_applicant.dart';
import 'package:flooding_v2/feature/study/domain/study_repository.dart';
import 'package:flooding_v2/feature/study/presentation/usecases/get_study_applicants_usecase.dart';

/// 테스트용 [StudyRepository] — fetchApplicants 결과/예외를 주입한다.
class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository({this.applicants = const [], this.error});

  final List<StudyApplicant> applicants;
  final Object? error;

  @override
  Future<List<StudyApplicant>> fetchApplicants() async {
    if (error != null) throw error!;
    return applicants;
  }

  @override
  Future<void> requestStudy() async {}

  @override
  Future<void> cancelStudy() async {}
}

void main() {
  group('GetStudyApplicantsUseCase 매핑', () {
    test('학년·반·번호가 있으면 4자리 학번으로 합성한다', () async {
      final usecase = GetStudyApplicantsUseCase(
        _FakeStudyRepository(
          applicants: const [
            StudyApplicant(
              id: 1,
              name: '김민솔',
              studentNumber: 9999,
              grade: 2,
              classNumber: 4,
              number: 3,
              sex: 'WOMAN',
            ),
          ],
        ),
      );

      final members = await usecase();

      expect(members, hasLength(1));
      expect(members.first.name, '김민솔');
      expect(members.first.schoolNb, 2403);
      expect(members.first.gender, Gender.female);
    });

    test('학년·반·번호가 없으면 studentNumber 를 학번으로 사용한다', () async {
      final usecase = GetStudyApplicantsUseCase(
        _FakeStudyRepository(
          applicants: const [
            StudyApplicant(
              id: 2,
              name: '이재현',
              studentNumber: 1101,
              sex: 'MAN',
            ),
          ],
        ),
      );

      final members = await usecase();

      expect(members.first.schoolNb, 1101);
      expect(members.first.gender, Gender.male);
    });

    test('sex 가 없으면 기본값 male 로 매핑한다', () async {
      final usecase = GetStudyApplicantsUseCase(
        _FakeStudyRepository(
          applicants: const [
            StudyApplicant(id: 3, name: '미상', studentNumber: 3303),
          ],
        ),
      );

      final members = await usecase();
      expect(members.first.gender, Gender.male);
    });

    test('StudyException 은 메시지를 가진 Exception 으로 변환한다', () async {
      final usecase = GetStudyApplicantsUseCase(
        _FakeStudyRepository(
          error: const StudyException(
            StudyFailureReason.network,
            '네트워크 연결을 확인해 주세요.',
          ),
        ),
      );

      expect(
        () => usecase(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('네트워크 연결을 확인해 주세요.'),
          ),
        ),
      );
    });
  });
}
