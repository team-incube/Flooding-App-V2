/// SchoolView → SchoolDetailView 로 넘기는 층/교시 선택값(go_router `extra`).
class SchoolSeatSelection {
  const SchoolSeatSelection({required this.floor, required this.periods});

  final int? floor;
  final Set<int> periods;
}
