import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final int quantity;
  final int threshold;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.threshold,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>?;
    return InventoryItem(
      id: doc.id,
      name: data?['name'] ?? 'Unknown',
      quantity: data?['quantity'] ?? 0,
      threshold: data?['threshold'] ?? 0,
    );
  }
}
