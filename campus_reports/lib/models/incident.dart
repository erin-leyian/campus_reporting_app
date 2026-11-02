import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String reporterId;
  final String reporterName;
  final String? photoUrl;
  final bool isAnonymous;
  final DateTime? createdAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    this.photoUrl,
    this.isAnonymous = false,
    this.createdAt,
  });

  bool get isUrgent => category == 'Safety';

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Incident(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: d['category'] ?? 'Other',
      location: d['location'] ?? '',
      status: d['status'] ?? 'Submitted',
      reporterId: d['reporterId'] ?? '',
      reporterName: d['reporterName'] ?? '',
      photoUrl: d['photoUrl'],
      isAnonymous: d['isAnonymous'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'location': location,
    'status': status,
    'reporterId': reporterId,
    'reporterName': reporterName,
    'photoUrl': photoUrl,
    'isAnonymous': isAnonymous,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
