import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/status_chip.dart';
import '../../utils/constants.dart';
import '../../widgets/status_stepper.dart';

class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    final provider = context.read<IncidentProvider>();
    Navigator.pop(context); // leave the detail screen first
    await provider.deleteIncident(id);
  }

  Future<void> _changeStatus(
    BuildContext context,
    String id,
    String status,
  ) async {
    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.updateStatus(id, status);
      messenger.showSnackBar(SnackBar(content: Text('Status set to $status')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Not allowed, or the update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = context.watch<IncidentProvider>().byId(incidentId);
    final auth = context.watch<AuthProvider>();
    final uid = auth.user?.uid;
    final isStaff = auth.isStaff;

    if (i == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Report not found')),
      );
    }

    final isOwner = i.reporterId == uid;
    final canDelete = isOwner && i.status == 'Submitted';
    final reporter = i.isAnonymous
        ? (isOwner ? 'You (anonymous)' : 'Anonymous')
        : i.reporterName;
    final date = i.createdAt == null
        ? '—'
        : i.createdAt!.toLocal().toString().substring(0, 16);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report details'),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, i.id),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              StatusChip(i.status),
              if (i.isUrgent) ...[
                const SizedBox(width: 8),
                const Chip(
                  label: Text('Urgent'),
                  avatar: Icon(Icons.priority_high, size: 16),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(i.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          StatusStepper(i.status),
          const SizedBox(height: 16),
          _InfoRow(Icons.category_outlined, 'Category', i.category),
          _InfoRow(Icons.place_outlined, 'Location', i.location),
          _InfoRow(Icons.person_outline, 'Reported by', reporter),
          _InfoRow(Icons.schedule, 'Submitted', date),
          const Divider(height: 32),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(i.description),
          if (i.photoUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                i.photoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (c, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (c, e, s) => const SizedBox(
                  height: 80,
                  child: Center(child: Text('Could not load photo')),
                ),
              ),
            ),
          ],
          if (isStaff) ...[
            const Divider(height: 32),
            Text(
              'Update status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.statuses
                  .map(
                    (s) => ChoiceChip(
                      label: Text(s),
                      selected: i.status == s,
                      onSelected: (_) => _changeStatus(context, i.id, s),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
