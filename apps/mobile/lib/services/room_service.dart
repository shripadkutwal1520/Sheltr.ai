import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Room>> streamRooms() {
    return _db.collection('rooms').orderBy('number').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Room.fromFirestore(doc))
            .toList());
  }

  Future<void> toggleStatus(String id, bool currentAvailability) async {
    await _db.collection('rooms').doc(id).update({
      'isAvailable': !currentAvailability,
    });
  }
}
