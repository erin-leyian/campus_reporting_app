import 'dart:async';

import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service = IncidentService();
  StreamSubscription<List<Incident>>? _sub;

  List<Incident> _all = [];
  bool _loading = true;
  String? _error;

  String _search = '';
  String? _category;
  String? _status;
  bool _mineOnly = false;
  String? _uid;

  bool get isLoading => _loading;
  String? get error => _error;
  String? get categoryFilter => _category;
  String? get statusFilter => _status;
  bool get mineOnly => _mineOnly;

  bool get hasFilters =>
      _search.isNotEmpty || _category != null || _status != null || _mineOnly;

  Incident? byId(String id) {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// The list screens show: all reports after search and filters.
  List<Incident> get incidents {
    return _all.where((i) {
      if (_mineOnly && i.reporterId != _uid) return false;
      if (_category != null && i.category != _category) return false;
      if (_status != null && i.status != _status) return false;
      if (_search.isNotEmpty &&
          !i.title.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  void listen(String uid) {
    _uid = uid;
    _sub?.cancel();
    _loading = true;
    _sub = _service.incidentsStream().listen(
      (data) {
        _all = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        _error = 'Could not load reports.';
        notifyListeners();
      },
    );
  }

  void stop() {
    _sub?.cancel();
    _all = [];
    _search = '';
    _category = null;
    _status = null;
    _mineOnly = false;
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  void setCategory(String? v) {
    _category = v;
    notifyListeners();
  }

  void setStatus(String? v) {
    _status = v;
    notifyListeners();
  }

  void setMineOnly(bool v) {
    _mineOnly = v;
    notifyListeners();
  }

  void clearFilters() {
    _search = '';
    _category = null;
    _status = null;
    _mineOnly = false;
    notifyListeners();
  }

  Future<void> updateStatus(String id, String status) =>
      _service.updateStatus(id, status);

  Future<void> deleteIncident(String id) => _service.delete(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool _submitting = false;
  bool get isSubmitting => _submitting;

  Future<bool> submit({
    required String title,
    required String description,
    required String category,
    required String location,
    required String reporterId,
    required String reporterName,
    bool isAnonymous = false,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      await _service.create(
        Incident(
          id: '',
          title: title.trim(),
          description: description.trim(),
          category: category,
          location: location,
          status: 'Submitted',
          reporterId: reporterId,
          reporterName: reporterName,
          isAnonymous: isAnonymous,
        ),
      );
      return true;
    } catch (_) {
      _error = 'Could not submit the report. Please try again.';
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
