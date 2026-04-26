import 'package:flutter/material.dart';
import '../../models/inventory.dart';
import '../../services/inventory_service.dart';

class InventoryTab extends StatelessWidget {
  final InventoryService _service = InventoryService();

  InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: _service.streamInventory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading inventory: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final items = snapshot.data!;

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isLow = item.quantity <= item.threshold;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: isLow ? Colors.red.shade50 : null,
              child: ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLow ? Colors.red.shade900 : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Quantity: ${item.quantity} (Threshold: ${item.threshold})',
                  style: TextStyle(
                    color: isLow ? Colors.red.shade700 : Colors.grey.shade600,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: item.quantity <= 0 ? Colors.grey : Colors.red,
                      onPressed: item.quantity <= 0
                          ? null // Disable button if <= 0
                          : () => _service.updateQuantity(item.id, -1),
                    ),
                    Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                      onPressed: () => _service.updateQuantity(item.id, 1),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
