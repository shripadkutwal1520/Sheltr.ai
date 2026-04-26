import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory.dart';

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<InventoryItem>> streamInventory() {
    return _db.collection('inventory').orderBy('name').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromFirestore(doc))
            .toList());
  }

  Future<void> updateQuantity(String id, int delta) async {
    // Relying on UI to validate that quantity > 0 before calling this with negative delta
    await _db.collection('inventory').doc(id).update({
      'quantity': FieldValue.increment(delta),
    });
  }
}
