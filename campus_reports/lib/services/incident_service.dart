import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';

class IncidentService {
  final _col = FirebaseFirestore.instance.collection('incidents');

  Stream<List<Incident>> incidentsStream() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Incident.fromDoc).toList());
  }

  /// Returns the new document id, so a photo can be attached to it.
  Future<String> create(Incident incident) async {
    final ref = await _col.add(incident.toMap());
    return ref.id;
  }

  Future<void> setPhotoUrl(String id, String url) =>
      _col.doc(id).update({'photoUrl': url});

  Future<void> updateStatus(String id, String status) => _col.doc(id).update({
    'status': status,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> updateDescription(String id, String description) =>
      _col.doc(id).update({
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) => _col.doc(id).delete();
}
