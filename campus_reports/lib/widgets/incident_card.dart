import 'package:flutter/material.dart';

import '../models/incident.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;
  const IncidentCard({super.key, required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          incident.isUrgent
              ? Icons.priority_high
              : Icons.report_problem_outlined,
          color: incident.isUrgent ? Colors.red : null,
        ),
        title: Text(
          incident.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${incident.category} · ${incident.location}'),
        trailing: StatusChip(incident.status),
      ),
    );
  }
}
