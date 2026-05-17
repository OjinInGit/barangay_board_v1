import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../models/announcement.dart';
import '../../services/firestore_service.dart';
import '../../widgets/announcement_body_view.dart';
import 'create_announcement_screen.dart';

class AnnouncementsManageScreen extends StatelessWidget {
  const AnnouncementsManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final fs = FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);
    final dateFmt = DateFormat.yMMMd();
    final timeFmt = DateFormat.jm();
    return Scaffold(
      appBar: AppBar(title: Text(s.announcements)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const CreateAnnouncementScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<AnnouncementModel>>(
        stream: fs.announcementsStream(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text(s.genericError));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) return Center(child: Text(s.noAnnouncements));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              final a = list[i];
              return Card(
                child: ExpansionTile(
                  title: Text(
                    a.type.displayLabel(s, a.customTag),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${dateFmt.format(a.createdAt)}    ${timeFmt.format(a.createdAt)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: AnnouncementBodyView(body: a.body, maxHeight: 200),
                    ),
                    ButtonBar(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CreateAnnouncementScreen(existing: a),
                            ),
                          ),
                          child: Text(s.edit),
                        ),
                        TextButton(
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(s.delete),
                                content: Text(s.deleteAnnouncementConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(s.cancel),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(s.delete),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) await fs.deleteAnnouncement(a.id);
                          },
                          child: Text(s.delete),
                        ),
                      ],
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
