// lib/Page/floor_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FloorData {
  // Singleton Pattern
  static final FloorData _instance = FloorData._internal();
  factory FloorData() => _instance;
  FloorData._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Floor>> getFloorsStream() {
    return _firestore.collection('floors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Floor(
          id: doc.id,
          title: data['name'] ?? data['title'] ?? 'មិនស្គាល់ជាន់',
          roomCount: "${data['roomCount'] ?? 0} បន្ទប់",
        );
      }).toList();
    });
  }

  Future<List<Floor>> getFloorsOnce() async {
    final snapshot = await _firestore.collection('floors').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Floor(
        id: doc.id,
        title: data['name'] ?? data['title'] ?? 'មិនស្គាល់ជាន់',
        roomCount: "${data['roomCount'] ?? 0} បន្ទប់",
      );
    }).toList();
  }
}

class Floor {
  final String id;
  final String title;
  final String roomCount;

  Floor({
    required this.id,
    required this.title,
    required this.roomCount,
  });
}
