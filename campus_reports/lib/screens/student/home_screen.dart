import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/incident_card.dart';
import 'incident_detail_screen.dart';
import 'report_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user!.uid;
      context.read<IncidentProvider>().listen(uid);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final list = p.incidents;
    final isStaff = context.watch<AuthProvider>().isStaff;

    return Scaffold(
      appBar: AppBar(
        title: Text(isStaff ? 'Staff · Campus Reports' : 'Campus Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<IncidentProvider>().stop();
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Report'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _search,
              onChanged: p.setSearch,
              decoration: const InputDecoration(
                hintText: 'Search by title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('My reports'),
                  selected: p.mineOnly,
                  onSelected: p.setMineOnly,
                ),
                const SizedBox(width: 8),
                _FilterMenu(
                  label: 'Category',
                  value: p.categoryFilter,
                  options: AppConstants.categories,
                  onChanged: p.setCategory,
                ),
                const SizedBox(width: 8),
                _FilterMenu(
                  label: 'Status',
                  value: p.statusFilter,
                  options: AppConstants.statuses,
                  onChanged: p.setStatus,
                ),
                if (p.hasFilters)
                  TextButton(
                    onPressed: () {
                      _search.clear();
                      p.clearFilters();
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildList(p, list)),
        ],
      ),
    );
  }

  Widget _buildList(IncidentProvider p, List list) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) return Center(child: Text(p.error!));
    if (list.isEmpty) {
      return Center(
        child: Text(
          p.hasFilters
              ? 'No reports match your filters'
              : 'No reports yet. Tap Report to add one.',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: list.length,
      itemBuilder: (context, i) => IncidentCard(
        incident: list[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncidentDetailScreen(incidentId: list[i].id),
          ),
        ),
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _FilterMenu({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) => onChanged(v == '__all' ? null : v),
      itemBuilder: (_) => [
        const PopupMenuItem(value: '__all', child: Text('All')),
        ...options.map((o) => PopupMenuItem(value: o, child: Text(o))),
      ],
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value ?? label),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}
