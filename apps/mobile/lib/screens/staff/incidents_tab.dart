import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/incident.dart';

class IncidentsTab extends StatelessWidget {
  const IncidentsTab({super.key});

  Color _severityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _incidentIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'medical':
        return Icons.medical_services;
      case 'crime':
        return Icons.local_police;
      case 'accident':
        return Icons.car_crash;
      default:
        return Icons.report;
    }
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return 'Unknown';
    final month = dt.month.toString();
    final day = dt.day.toString();
    final hour = dt.hour.toString();
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('incidents')
          .where('timestamp', isGreaterThan: Timestamp(0, 0))
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snap.error}'),
              ],
            ),
          );
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snap.data!.docs[index];
            final incident = Incident.fromFirestore(doc);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _severityColor(incident.severity),
                  child: Icon(
                    _incidentIcon(incident.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  (incident.type ?? 'Unknown').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Severity: ${(incident.severity ?? 'unknown').toUpperCase()}',
                  style: TextStyle(
                    color: _severityColor(incident.severity),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  _formatTimestamp(incident.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => _showIncidentDetails(context, incident),
              ),
            );
          },
        );
      },
    );
  }

  void _showIncidentDetails(BuildContext context, Incident incident) {
    final isResolved = incident.status?.toLowerCase() == 'resolved';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (incident.type ?? 'Unknown').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isResolved ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (incident.status ?? 'active').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Severity', (incident.severity ?? 'unknown').toUpperCase()),
            _detailRow('Location', incident.location ?? 'Unknown'),
            _detailRow('Description', incident.description ?? 'None'),
            _detailRow('Reported', _formatTimestamp(incident.timestamp)),
            const SizedBox(height: 20),
            if (!isResolved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _resolveIncident(ctx, incident),
                  child: const Text('Mark as Resolved'),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolveIncident(BuildContext context, Incident incident) async {
    try {
      await FirebaseFirestore.instance
          .collection('incidents')
          .doc(incident.id)
          .update({'status': 'resolved'});

      if (context.mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incident marked as resolved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
