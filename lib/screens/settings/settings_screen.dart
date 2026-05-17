import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_locale.dart';
import '../../l10n/app_strings.dart';
import '../../models/app_models.dart';
import '../../services/prefs_service.dart';
import '../auth/login_screen.dart';
import '../language_onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final appLocale = AppLocaleScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              s.loggedInAs(profile.username),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _SettingsTile(
            icon: Icons.language,
            label: s.language,
            onTap: () async {
              final prefs = await PrefsService.create();
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LanguageOnboardingScreen(
                    prefs: prefs,
                    appLocale: appLocale,
                    returnAfterPick: true,
                  ),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.logout,
            label: s.logout,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(s.logout),
                  content: Text(s.logoutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(s.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(s.logout),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                  (r) => false,
                );
              }
            },
          ),
          _SettingsTile(
            icon: Icons.exit_to_app,
            label: s.exitApp,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(s.exitApp),
                  content: Text(s.exitConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(s.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(s.exitApp),
                    ),
                  ],
                ),
              );
              if (ok == true) SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
        title: Text(label, style: Theme.of(context).textTheme.titleLarge),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}

/// Inherited wrapper for [AppLocale].
class AppLocaleScope extends InheritedNotifier<AppLocale> {
  const AppLocaleScope({
    super.key,
    required AppLocale appLocale,
    required super.child,
  }) : super(notifier: appLocale);

  static AppLocale of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found');
    return scope!.notifier!;
  }
}
