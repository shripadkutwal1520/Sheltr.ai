import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String number;
  final bool isAvailable;

  Room({
    required this.id,
    required this.number,
    required this.isAvailable,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>?;
    return Room(
      id: doc.id,
      number: data?['number'] ?? 'Unknown',
      isAvailable: data?['isAvailable'] ?? true, // Default to available
    );
  }
}
