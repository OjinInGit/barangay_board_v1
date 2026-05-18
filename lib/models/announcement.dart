import 'package:cloud_firestore/cloud_firestore.dart';

import 'announcement_type.dart';

class AnnouncementModel {
  AnnouncementModel({
    required this.id,
    required this.type,
    required this.body,
    required this.createdAt,
    this.customTag,
    this.authorUid,
  });

  final String id;
  final AnnouncementType type;
  final String body;
  final DateTime createdAt;
  final String? customTag;
  final String? authorUid;

  factory AnnouncementModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AnnouncementModel(
      id: doc.id,
      type: AnnouncementType.fromCode(d['type'] as String?),
      body: (d['body'] as String?) ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customTag: (d['customTag'] ?? d['customLabel']) as String?,
      authorUid: d['authorUid'] as String?,
    );
  }

  Map<String, dynamic> toMap(String authorUid) => {
        'type': type.code,
        'body': body,
        'createdAt': FieldValue.serverTimestamp(),
        if (type == AnnouncementType.customTag && customTag != null)
          'customTag': customTag,
        'authorUid': authorUid,
      };
}

int compareAnnouncementsBySeverity(AnnouncementModel a, AnnouncementModel b) {
  final byType = a.type.severityRank.compareTo(b.type.severityRank);
  if (byType != 0) return byType;
  return b.createdAt.compareTo(a.createdAt);
}
