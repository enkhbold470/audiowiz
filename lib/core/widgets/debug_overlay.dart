import 'package:flutter/material.dart';

class DebugOverlay extends StatelessWidget {
  final List<String> logs;
  
  const DebugOverlay({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Debug Info', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    // Clear logs functionality can be added here
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white30),
            ...logs.map((log) => Text(
              log,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            )).toList(),
          ],
        ),
      ),
    );
  }
} 