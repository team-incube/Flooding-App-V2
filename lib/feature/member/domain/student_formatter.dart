class StudentFormatter {
  static int formatSchoolNumber({
    required int? grade,
    required int? classNumber,
    required int? number,
    required int studentNumber,
  }) {
    if (grade != null && classNumber != null && number != null) {
      return grade * 1000 + classNumber * 100 + number;
    }
    return studentNumber;
  }

  static int parseGrade(int studentNumber) => studentNumber ~/ 1000;

  static int parseClassNumber(int studentNumber) => (studentNumber ~/ 100) % 10;

  static int parseNumber(int studentNumber) => studentNumber % 100;
}
