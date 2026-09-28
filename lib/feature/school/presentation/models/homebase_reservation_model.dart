class HomebaseReservationStudent {
  final int schoolNb;
  final String name;

  HomebaseReservationStudent({required this.schoolNb, required this.name});
}

class HomebaseReservationModel {
  final int id;
  final int floor;
  final int tableNumber;
  final List<HomebaseReservationStudent> students;
  final List<int> periods;

  HomebaseReservationModel({
    required this.id,
    required this.floor,
    required this.tableNumber,
    required this.students,
    required this.periods,
  });
}
