import '../l10n/app_strings.dart';

final _lettersOnly = RegExp(r'^[A-Za-z\s\-\.]+$');
final _suffixLetters = RegExp(r'^[A-Za-z\s\-\.]*$');
final _emailFormat = RegExp(
  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
);

String? validateRequired(AppStrings s, String? value) {
  if (value == null || value.trim().isEmpty) return s.fieldRequired;
  return null;
}

String? validateNameLetters(AppStrings s, String? value, {bool required = true}) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return required ? s.fieldRequired : null;
  if (!_lettersOnly.hasMatch(t)) return s.errNameLettersOnly;
  return null;
}

String? validateSuffix(AppStrings s, String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return null;
  if (!_suffixLetters.hasMatch(t)) return s.errNameLettersOnly;
  return null;
}

String? validateMiddleInitial(AppStrings s, String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return null;
  if (!RegExp(r'^[A-Z]$').hasMatch(t)) return s.invalidMiddleInitial;
  return null;
}

String? validateEmailFormat(AppStrings s, String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return s.fieldRequired;
  if (!_emailFormat.hasMatch(t)) return s.errInvalidEmailFormat;
  return null;
}

String? validateUsername(AppStrings s, String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return s.fieldRequired;
  if (t.length < 3) return s.errUsernameTooShort;
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(t)) return s.errUsernameInvalid;
  return null;
}
