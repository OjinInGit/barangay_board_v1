import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'app_locale.dart';
import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_strings.dart';
import 'models/app_models.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/language_onboarding_screen.dart';
import 'screens/resident/resident_home_screen.dart';
import 'screens/settings/settings_screen.dart' show AppLocaleScope;
import 'screens/splash_screen.dart';
import 'services/firestore_service.dart';
import 'services/messaging_service.dart';
import 'services/prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MessagingService.instance.initialize();
  final prefs = await PrefsService.create();
  final localeCode = prefs.localeCode ?? 'en';
  runApp(BarangayBoardApp(prefs: prefs, initialLocale: localeCode));
}

class BarangayBoardApp extends StatefulWidget {
  const BarangayBoardApp({
    super.key,
    required this.prefs,
    required this.initialLocale,
  });

  final PrefsService prefs;
  final String initialLocale;

  @override
  State<BarangayBoardApp> createState() => _BarangayBoardAppState();
}

class _BarangayBoardAppState extends State<BarangayBoardApp> {
  late final AppLocale _appLocale;

  @override
  void initState() {
    super.initState();
    _appLocale = AppLocale(widget.initialLocale);
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      appLocale: _appLocale,
      child: ListenableBuilder(
        listenable: _appLocale,
        builder: (context, _) {
          final s = AppStrings(_appLocale.code);
          return MaterialApp(
            title: s.appName,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
            locale: _appLocale.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('fil'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            home: _RootGate(prefs: widget.prefs, appLocale: _appLocale),
          );
        },
      ),
    );
  }
}

class _RootGate extends StatefulWidget {
  const _RootGate({required this.prefs, required this.appLocale});

  final PrefsService prefs;
  final AppLocale appLocale;

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    if (!widget.prefs.languageOnboarded) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LanguageOnboardingScreen(
            prefs: widget.prefs,
            appLocale: widget.appLocale,
          ),
        ),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
      return;
    }
    final fs = FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);
    final profile = await fs.profileForUid(user.uid);
    if (!mounted) return;
    if (profile == null || !profile.active) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
      return;
    }
    if (!widget.prefs.notificationPromptDone) {
      await _notificationPrompt();
    }
    if (profile.role == UserRole.resident) {
      await MessagingService.instance.subscribeResidentTopics();
      final token = await MessagingService.instance.getToken();
      if (token != null) await fs.updateFcmToken(token);
    }
    if (!mounted) return;
    if (profile.role == UserRole.admin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AdminHomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResidentHomeScreen(username: profile.username),
        ),
      );
    }
  }

  Future<void> _notificationPrompt() async {
    final s = AppStrings(widget.appLocale.code);
    final allow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(s.notificationPromptTitle),
        content: Text(s.notificationPromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.allowNotifications),
          ),
        ],
      ),
    );
    if (allow == true) {
      await MessagingService.instance.requestPermissionIfNeeded();
    }
    await widget.prefs.setNotificationPromptDone(true);
  }

  @override
  Widget build(BuildContext context) => const SplashScreen();
}
