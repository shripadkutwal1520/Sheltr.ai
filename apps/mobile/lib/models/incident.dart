import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String type;        // "panic"
  final String severity;    // "critical", "high", "medium", "low"
  final String status;      // "active", "resolved"
  final DateTime? timestamp;
  final double? latitude;
  final double? longitude;
  final String userId;
  final String? description;
  final String? location;

  Incident({
    required this.id,
    required this.type,
    required this.severity,
    required this.status,
    this.timestamp,
    this.latitude,
    this.longitude,
    required this.userId,
    this.description,
    this.location,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'severity': severity,
    'status': status,
    'timestamp': FieldValue.serverTimestamp(),
    'latitude': latitude,
    'longitude': longitude,
    'userId': userId,
  };

  factory Incident.fromMap(String id, Map<String, dynamic> map) => Incident(
    id: id,
    type: map['type'] ?? 'panic',
    severity: map['severity'] ?? 'pending',
    status: map['status'] ?? 'active',
    timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    latitude: (map['latitude'] as num?)?.toDouble(),
    longitude: (map['longitude'] as num?)?.toDouble(),
    userId: map['userId'] ?? '',
    description: map['description'],
    location: map['location'],
  );

  factory Incident.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Incident(
      id: doc.id,
      type: data['type'] ?? 'panic',
      severity: data['severity'] ?? 'pending',
      status: data['status'] ?? 'active',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      userId: data['userId'] ?? '',
      description: data['description'],
      location: data['location'],
    );
  }
}
