import 'package:flutter/material.dart';

import '../app_locale.dart';
import '../l10n/app_strings.dart';
import '../services/prefs_service.dart';
import 'auth/login_screen.dart';

class LanguageOnboardingScreen extends StatelessWidget {
  const LanguageOnboardingScreen({
    super.key,
    required this.prefs,
    required this.appLocale,
    this.returnAfterPick = false,
  });

  final PrefsService prefs;
  final AppLocale appLocale;
  final bool returnAfterPick;

  Future<void> _pick(BuildContext context, String code) async {
    await prefs.setLocaleCode(code);
    await prefs.setLanguageOnboarded(true);
    appLocale.setLocale(code);
    if (!context.mounted) return;
    if (returnAfterPick) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.chooseLanguage)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.chooseLanguage, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _pick(context, 'en'),
              child: Text(s.english),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _pick(context, 'fil'),
              child: Text(s.filipino),
            ),
          ],
        ),
      ),
    );
  }
}
