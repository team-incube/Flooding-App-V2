import '../repositories/study_repository.dart';

/// 자습 신청을 취소한다.
///
/// 백엔드 오류가 발생하면 [StudyException] 을 던진다.
class CancelStudyUseCase {
  const CancelStudyUseCase(this._repository);

  final StudyRepository _repository;

  Future<void> call() => _repository.cancelStudy();
}
