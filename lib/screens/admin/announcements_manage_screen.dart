import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../models/announcement.dart';
import '../../services/announcement_share_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/announcement_body_view.dart';
import 'create_announcement_screen.dart';

class AnnouncementsManageScreen extends StatelessWidget {
  const AnnouncementsManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final fs = FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);
    final shareService = AnnouncementShareService();
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
              return _AnnouncementManageCard(
                announcement: a,
                dateLine:
                    '${dateFmt.format(a.createdAt)}    ${timeFmt.format(a.createdAt)}',
                strings: s,
                firestore: fs,
                shareService: shareService,
                onShare: () => _showShareMenu(context, a, s, shareService),
              );
            },
          );
        },
      ),
    );
  }

  void _showShareMenu(
    BuildContext context,
    AnnouncementModel a,
    AppStrings s,
    AnnouncementShareService shareService,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_snippet_outlined),
              title: Text(s.shareAsText),
              onTap: () {
                Navigator.pop(sheetContext);
                _runShare(
                  context,
                  s,
                  () => shareService.shareAsText(a, s),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(s.shareAsPdf),
              onTap: () {
                Navigator.pop(sheetContext);
                _runShare(
                  context,
                  s,
                  () => shareService.shareAsPdf(a, s),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _runShare(
    BuildContext context,
    AppStrings s,
    Future<void> Function() action,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      try {
        await action();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.shareFailed)),
          );
        }
      }
    });
  }
}

/// Share sits outside [ExpansionTile] so its tap is not swallowed by expand/collapse.
class _AnnouncementManageCard extends StatefulWidget {
  const _AnnouncementManageCard({
    required this.announcement,
    required this.dateLine,
    required this.strings,
    required this.firestore,
    required this.shareService,
    required this.onShare,
  });

  final AnnouncementModel announcement;
  final String dateLine;
  final AppStrings strings;
  final FirestoreService firestore;
  final AnnouncementShareService shareService;
  final VoidCallback onShare;

  @override
  State<_AnnouncementManageCard> createState() => _AnnouncementManageCardState();
}

class _AnnouncementManageCardState extends State<_AnnouncementManageCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final a = widget.announcement;
    final fs = widget.firestore;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.type.displayLabel(s, a.customTag),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(widget.dateLine),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: s.share,
                  onPressed: widget.onShare,
                ),
                IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: _expanded ? s.collapse : s.expand,
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: AnnouncementBodyView(
                body: a.body,
                maxHeight: 200,
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CreateAnnouncementScreen(existing: a),
                    ),
                  ),
                  child: Text(s.edit),
                ),
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(s.archive),
                        content: Text(s.archiveAnnouncementConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(s.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(s.archive),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) await fs.archiveAnnouncement(a.id);
                  },
                  child: Text(s.archive),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
