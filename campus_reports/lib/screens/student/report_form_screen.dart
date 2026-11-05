import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../../services/storage_service.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? _category;
  String? _location;
  Uint8List? _photoBytes;
  String? _photoName;
  bool _anonymous = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    if (bytes.length > StorageService.maxBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo is too large (max 5 MB)')),
      );
      return;
    }
    setState(() {
      _photoBytes = bytes;
      _photoName = picked.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user!;
    final provider = context.read<IncidentProvider>();

    final ok = await provider.submit(
      title: _title.text,
      description: _description.text,
      category: _category!,
      location: _location!,
      reporterId: user.uid,
      reporterName: user.displayName ?? 'Student',
      isAnonymous: _anonymous,
      photoBytes: _photoBytes,
      photoName: _photoName,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Report submitted' : (provider.error ?? 'Failed')),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<IncidentProvider>().isSubmitting;
    return Scaffold(
      appBar: AppBar(title: const Text('Report an issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, 'Title'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Choose a category' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _location,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.locations
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _location = v),
                validator: (v) => v == null ? 'Choose a location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: Validators.description,
              ),
              if (_photoBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _photoBytes!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _photoBytes = null;
                    _photoName = null;
                  }),
                  icon: const Icon(Icons.close),
                  label: const Text('Remove photo'),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Report anonymously'),
                subtitle: const Text('Staff will not see your name'),
                value: _anonymous,
                onChanged: (v) => setState(() => _anonymous = v),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: submitting ? null : _submit,
                  child: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
