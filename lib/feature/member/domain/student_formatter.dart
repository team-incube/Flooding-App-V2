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
}