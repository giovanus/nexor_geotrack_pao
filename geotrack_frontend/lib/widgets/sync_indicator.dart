import 'package:flutter/material.dart';

class SyncIndicator extends StatelessWidget {
  final int pendingCount;

  const SyncIndicator({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: pendingCount > 0 ? Colors.blue : Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sync, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            pendingCount > 0 ? '$pendingCount pending sync' : 'All data synced',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
