import '../l10n/app_strings.dart';

String? validateRegistrationPassword(AppStrings s, String? value) {
  final p = value ?? '';
  if (p.length < 8) return s.errWeakPassword;
  if (!RegExp(r'[A-Z]').hasMatch(p)) return s.errWeakPassword;
  if (!RegExp(r'[a-z]').hasMatch(p)) return s.errWeakPassword;
  if (!RegExp(r'[0-9]').hasMatch(p)) return s.errWeakPassword;
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]\\;/+=]').hasMatch(p)) {
    return s.errWeakPassword;
  }
  return null;
}
