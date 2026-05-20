import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/branding_app_bar_title.dart';
import '../settings/settings_screen.dart';
import 'announcements_manage_screen.dart';
import 'archived_announcements_screen.dart';
import 'create_announcement_screen.dart';
import 'residents_list_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<UserProfile?> _profile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance)
        .profileForUid(uid);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: BrandingAppBarTitle(subtitle: s.adminDashboardSubtitle),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HomeTile(
            icon: Icons.people_outline,
            label: s.residents,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ResidentsListScreen(),
              ),
            ),
          ),
          _HomeTile(
            icon: Icons.campaign_outlined,
            label: s.makeAnnouncement,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CreateAnnouncementScreen(),
              ),
            ),
          ),
          _HomeTile(
            icon: Icons.article_outlined,
            label: s.announcements,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AnnouncementsManageScreen(),
              ),
            ),
          ),
          _HomeTile(
            icon: Icons.archive_outlined,
            label: s.archivedAnnouncements,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ArchivedAnnouncementsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
