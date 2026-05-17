import 'package:cloud_firestore/cloud_firestore.dart';

import '../l10n/app_strings.dart';
import 'announcement_type.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.type,
    required this.bodyJson,
    required this.createdAt,
    this.customLabel,
    this.authorUid,
  });

  final String id;
  final AnnouncementType type;
  final String bodyJson;
  final DateTime createdAt;
  final String? customLabel;
  final String? authorUid;

  String typeLabel(AppStrings s) => type.label(s, customLabel: customLabel);

  factory Announcement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['createdAt'];
    DateTime created = DateTime.now();
    if (ts is Timestamp) created = ts.toDate();
    final t =
        announcementTypeFromString(d['type'] as String?) ??
        AnnouncementType.publicNotice;
    return Announcement(
      id: doc.id,
      type: t,
      bodyJson: (d['body'] as String?) ?? '',
      createdAt: created,
      customLabel: d['customLabel'] as String?,
      authorUid: d['authorUid'] as String?,
    );
  }

  Map<String, dynamic> toCreateMap({
    required String bodyJson,
    required String? authorUid,
  }) => {
    'type': type.storageKey,
    'body': bodyJson,
    'createdAt': FieldValue.serverTimestamp(),
    if (customLabel != null && customLabel!.trim().isNotEmpty)
      'customLabel': customLabel!.trim(),
    'authorUid': ?authorUid,
  };

  static int compareBySeverityThenNewest(Announcement a, Announcement b) {
    final bySeverity = a.type.severityRank.compareTo(b.type.severityRank);
    if (bySeverity != 0) return bySeverity;
    return b.createdAt.compareTo(a.createdAt);
  }
}
