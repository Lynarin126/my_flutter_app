// lib/Page/floor_data.dart

class FloorData {
  // Singleton - ធានាថាមាន Instance តែមួយ Share គ្រប់ Page
  static final FloorData _instance = FloorData._internal();
  factory FloorData() => _instance;
  FloorData._internal();

  // List ជាន់ Share គ្រប់ Page
  List<Floor> floors = [
    Floor(title: "ជាន់ ទី១១", roomCount: "១ បន្ទប់"),
    Floor(title: "ជាន់ ទី១០", roomCount: "១ បន្ទប់"),
    Floor(title: "ជាន់ ទី៩",  roomCount: "១ បន្ទប់"),
    Floor(title: "ជាន់ ទី៨",  roomCount: "១ បន្ទប់"),
    Floor(title: "ជាន់ ទី៧",  roomCount: "១ បន្ទប់"),
    Floor(title: "ជាន់ ទី៦",  roomCount: "១ បន្ទប់"),
  ];
}

class Floor {
  String title;
  String roomCount;
  Floor({required this.title, required this.roomCount});
}