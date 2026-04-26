import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/incident.dart';

class IncidentService {
  final CollectionReference _incidents = FirebaseFirestore.instance.collection('incidents');
  final HttpsCallable _triggerPanic = FirebaseFunctions.instance.httpsCallable('triggerPanic');

  Future<Incident?> createPanicIncident({double? lat, double? lng}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    double? finalLat = lat;
    double? finalLng = lng;

    // Attempt to fetch location with a 3-second timeout if not provided
    if (finalLat == null || finalLng == null) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 3),
          ),
        ).timeout(const Duration(seconds: 3));
        
        finalLat = position.latitude;
        finalLng = position.longitude;
      } catch (e) {
        debugPrint('[IncidentService] Location unavailable (proceeding with null): $e');
      }
    }

    try {
      final result = await _triggerPanic.call({
        'latitude': finalLat,
        'longitude': finalLng,
      });

      final data = result.data as Map<String, dynamic>;
      return Incident(
        id: data['incidentId'] as String,
        type: 'panic',
        severity: 'pending',
        status: 'active',
        timestamp: DateTime.now(),
        latitude: finalLat,
        longitude: finalLng,
        userId: user.uid,
      );
    } catch (e) {
      debugPrint('[IncidentService] Panic trigger failed: $e');
      return null;
    }
  }

  Stream<List<Incident>> streamActiveIncidents() {
    return _incidents
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
          final incidents = snap.docs.map((doc) => Incident.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
          incidents.sort((a, b) {
            final aTime = a.timestamp ?? DateTime.now();
            final bTime = b.timestamp ?? DateTime.now();
            return bTime.compareTo(aTime);
          });
          return incidents;
        });
  }

  Future<void> updateIncidentStatus(String id, String status) async {
    await _incidents.doc(id).update({'status': status});
  }
}
