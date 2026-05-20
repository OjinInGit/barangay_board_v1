import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../services/firestore_service.dart';
import '../../widgets/announcement_body_view.dart';

class ArchivedAnnouncementsScreen extends StatelessWidget {
  const ArchivedAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final fs = FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);
    final dateFmt = DateFormat.yMMMd();
    final timeFmt = DateFormat.jm();
    return Scaffold(
      appBar: AppBar(title: Text(s.archivedAnnouncements)),
      body: StreamBuilder(
        stream: fs.announcementsArchivedStream(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text(s.genericError));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) return Center(child: Text(s.noArchivedAnnouncements));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              final a = list[i];
              return Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ExpansionTile(
                  title: Text(
                    a.type.displayLabel(s, a.customTag),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${dateFmt.format(a.createdAt)}    ${timeFmt.format(a.createdAt)}'
                    '${a.archivedAt != null ? '\n${s.archive}: ${dateFmt.format(a.archivedAt!)}' : ''}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AnnouncementBodyView(
                        body: a.body,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
