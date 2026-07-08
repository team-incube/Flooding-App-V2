// 캘린더 공용 상수·헬퍼.

/// 월요일 시작 기준 요일 라벨. DateTime.weekday(월=1 … 일=7) - 1 로 인덱싱한다.
const List<String> kCalendarWeekdays = ['월', '화', '수', '목', '금', '토', '일'];

/// "26.07.08(수)" 형태로 헤더 날짜를 만든다.
String formatCalendarHeaderDate(DateTime d) {
  final yy = (d.year % 100).toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  final weekday = kCalendarWeekdays[d.weekday - 1];
  return '$yy.$mm.$dd($weekday)';
}

/// 연·월·일이 같은 날짜인지 비교한다(시각은 무시).
bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
