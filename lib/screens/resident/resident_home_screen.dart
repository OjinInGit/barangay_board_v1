import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_strings.dart';
import '../../models/announcement.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';
import '../../services/messaging_service.dart';
import '../../services/prefs_service.dart';
import '../../widgets/announcement_body_view.dart';
import '../../widgets/branding_app_bar_title.dart';
import '../settings/settings_screen.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key, required this.username});

  final String username;

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  PrefsService? _prefs;
  final _seenIds = <String>{};
  bool _primed = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    MessagingService.instance.listenForegroundMessages(_onForegroundMessage);
  }

  Future<void> _initPrefs() async {
    _prefs = await PrefsService.create();
    if (mounted) setState(() {});
  }

  void _onForegroundMessage(RemoteMessage message) {
    // Firebase Console notifications while the bulletin screen is open.
    MessagingService.instance.displayRemoteMessage(message);
  }

  void _trackNewAnnouncements(List<AnnouncementModel> list) {
    if (!_primed) {
      _seenIds.addAll(list.map((a) => a.id));
      _primed = true;
      return;
    }
    for (final a in list) {
      if (_seenIds.add(a.id)) {
        MessagingService.instance.showResidentForegroundAnnouncement(
          title: AppStrings.of(context).appName,
          body: a.type.displayLabel(AppStrings.of(context), a.customTag),
        );
      }
    }
  }

  Future<UserProfile?> _profile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance)
        .profileForUid(uid);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final fs = FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);
    final dateFmt = DateFormat.yMMMd();
    final timeFmt = DateFormat.jm();
    final prefs = _prefs;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: BrandingAppBarTitle(subtitle: s.residentBulletinSubtitle),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            final profile = await _profile();
            if (!context.mounted || profile == null) return;
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettingsScreen(profile: profile),
              ),
            );
          },
        ),
      ),
      body: prefs == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<AnnouncementModel>>(
              stream: fs.announcementsForResident(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text(s.genericError));
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data!;
                _trackNewAnnouncements(list);
                if (list.isEmpty) return Center(child: Text(s.noAnnouncements));
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final a = list[i];
                    final isRead = prefs.isAnnouncementRead(a.id);
                    final card = Card(
                      elevation: isRead ? 0 : 3,
                      shadowColor: isRead
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                      child: InkWell(
                        onTap: () async {
                          await prefs.markAnnouncementRead(a.id);
                          if (!context.mounted) return;
                          setState(() {});
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.6,
                              minChildSize: 0.35,
                              maxChildSize: 0.92,
                              builder: (_, controller) => Padding(
                                padding: const EdgeInsets.all(20),
                                child: ListView(
                                  controller: controller,
                                  children: [
                                    Text(
                                      a.type.displayLabel(s, a.customTag),
                                      style: Theme.of(ctx)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${dateFmt.format(a.createdAt)}    ${timeFmt.format(a.createdAt)}',
                                    ),
                                    const SizedBox(height: 16),
                                    AnnouncementBodyView(
                                      body: a.body,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(a.type.icon, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      a.type.displayLabel(s, a.customTag),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${dateFmt.format(a.createdAt)}    ${timeFmt.format(a.createdAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              AnnouncementBodyView(
                                body: a.body,
                                maxHeight: 72,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: isRead ? 0.55 : 1,
                      child: card,
                    );
                  },
                );
              },
            ),
    );
  }
}
