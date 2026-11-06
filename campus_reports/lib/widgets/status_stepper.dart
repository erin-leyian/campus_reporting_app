import 'package:flutter/material.dart';

import 'status_chip.dart';

class StatusStepper extends StatelessWidget {
  final String status;
  const StatusStepper(this.status, {super.key});

  static const steps = ['Submitted', 'In Review', 'In Progress', 'Resolved'];

  @override
  Widget build(BuildContext context) {
    if (status == 'Rejected') {
      return const Row(
        children: [
          Icon(Icons.cancel, color: Colors.grey),
          SizedBox(width: 8),
          Text('This report was rejected'),
        ],
      );
    }
    final current = steps.indexOf(status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (n) {
        if (n.isOdd) {
          final done = (n ~/ 2) < current;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                height: 3,
                color: done ? Colors.green : Colors.grey.shade300,
              ),
            ),
          );
        }
        final i = n ~/ 2;
        final reached = i <= current;
        return Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: reached
                  ? StatusChip.colorFor(steps[i])
                  : Colors.grey.shade300,
              child: reached
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(steps[i], style: const TextStyle(fontSize: 10)),
          ],
        );
      }),
    );
  }
}
