import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<IncidentService>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Your Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Active Emergency Monitoring', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Text('Staff View', style: TextStyle(fontSize: 10, color: Colors.red.shade800, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Incident>>(
              stream: service.streamActiveIncidents(),
              builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text('Failed to load alerts', style: TextStyle(fontSize: 16, color: Colors.red)),
              ],
            ),
          );
        }
        final incidents = snap.data ?? [];
        if (incidents.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('All Clear!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(height: 4),
                Text('No active emergencies.', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: incidents.length,
          itemBuilder: (context, i) => IncidentTile(incidents[i]),
        );
      },
            ),
          ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime? date) {
  if (date == null) return "Pending...";
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hr ago";
  return "${diff.inDays} days ago";
}

class IncidentTile extends StatelessWidget {
  final Incident incident;
  const IncidentTile(this.incident, {super.key});

  @override
  Widget build(BuildContext context) {
    final isPending = incident.severity?.toLowerCase() == 'pending';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: isPending ? Colors.orange : Colors.red, width: 6)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 36),
          title: const Text(
            "EMERGENCY ALERT",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const SizedBox(height: 4),
               Text(
                 "Status: ${incident.status.toUpperCase()}", 
                 style: TextStyle(color: isPending ? Colors.orange[800] : Colors.red[800], fontWeight: FontWeight.w600)
               ),
               const SizedBox(height: 2),
               Text(
                 _timeAgo(incident.timestamp), 
                 style: TextStyle(color: Colors.grey[600], fontSize: 12)
               ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
            onPressed: () {
              context.read<IncidentService>().updateIncidentStatus(incident.id, 'resolved');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incident marked as resolved by staff'), backgroundColor: Colors.green),
              );
            },
            tooltip: "Mark as resolved",
          ),
        ),
      ),
    );
  }
}
