import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import 'report_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to Firestore once, after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user!.uid;
      context.read<IncidentProvider>().listen(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Reports'),
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
      body: incidents.isLoading
          ? const Center(child: CircularProgressIndicator())
          : incidents.incidents.isEmpty
          ? const Center(child: Text('No reports yet'))
          : ListView(
              children: incidents.incidents
                  .map(
                    (i) => ListTile(
                      title: Text(i.title),
                      subtitle: Text('${i.category} · ${i.location}'),
                      trailing: Text(i.status),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
