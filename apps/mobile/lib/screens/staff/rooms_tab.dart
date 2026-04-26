import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

class RoomsTab extends StatelessWidget {
  final RoomService _service = RoomService();

  RoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
      stream: _service.streamRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading rooms: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final rooms = snapshot.data!;

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            final statusText = room.isAvailable ? 'Available' : 'Blocked';
            final statusColor = room.isAvailable ? Colors.green : Colors.red;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(
                    room.isAvailable ? Icons.door_front_door : Icons.block,
                    color: statusColor,
                  ),
                ),
                title: Text('Room ${room.number}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  statusText,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.w600),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor.withOpacity(0.1),
                    foregroundColor: statusColor,
                    elevation: 0,
                  ),
                  onPressed: () =>
                      _service.toggleStatus(room.id, room.isAvailable),
                  child: Text(room.isAvailable ? 'Block' : 'Unblock'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
