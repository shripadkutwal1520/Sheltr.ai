import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _safeZone = const LatLng(19.9975, 73.7898); // Example: Nashik Shelter
  Set<Polyline> _polylines = {};

  void _updatePolylines(List<Incident> incidents) {
    if (incidents.isEmpty) return;
    
    // For demo: draw a path from each incident to the safe zone
    final newPolylines = incidents
        .where((i) => i.latitude != null && i.longitude != null)
        .map((i) => Polyline(
              polylineId: PolylineId('route_${i.id}'),
              points: [LatLng(i.latitude!, i.longitude!), _safeZone],
              color: i.severity == 'critical' ? Colors.red : Colors.green,
              width: 4,
              patterns: [PatternItem.dash(10), PatternItem.gap(10)],
            ))
        .toSet();

    if (_polylines.length != newPolylines.length) {
      setState(() => _polylines = newPolylines);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<IncidentService>();

    return StreamBuilder<List<Incident>>(
      stream: service.streamActiveIncidents(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(child: Text('Error loading map', style: TextStyle(color: Colors.red)));
        }
        final incidents = snap.data ?? [];
        final incidentsWithLocation = incidents.where((i) => i.latitude != null && i.longitude != null).toList();

        // Update polylines whenever incidents change
        WidgetsBinding.instance.addPostFrameCallback((_) => _updatePolylines(incidentsWithLocation));

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: incidentsWithLocation.isNotEmpty
                    ? LatLng(incidentsWithLocation.first.latitude!, incidentsWithLocation.first.longitude!)
                    : _safeZone,
                zoom: 12,
              ),
              markers: {
                ...incidentsWithLocation.map((i) => Marker(
                  markerId: MarkerId(i.id),
                  position: LatLng(i.latitude!, i.longitude!),
                  infoWindow: InfoWindow(title: '${i.type} - ${i.severity?.toUpperCase()}'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    i.severity == 'critical' ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange
                  ),
                )),
                Marker(
                  markerId: const MarkerId('safe_zone'),
                  position: _safeZone,
                  infoWindow: const InfoWindow(title: 'SAFE ZONE / SHELTER'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
              },
              polylines: _polylines,
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [Icon(Icons.circle, size: 12, color: Colors.green), Text(' Safe Zone')]),
                    Row(children: [Icon(Icons.circle, size: 12, color: Colors.red), Text(' Critical Incident')]),
                    Row(children: [Icon(Icons.linear_scale, size: 12, color: Colors.green), Text(' Evacuation Path')]),
                  ],
                ),
              ),
            ),
            if (incidentsWithLocation.isEmpty)
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Text('No active incidents', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
