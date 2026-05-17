final _hasUpper = RegExp(r'[A-Z]');
final _hasLower = RegExp(r'[a-z]');
final _hasDigit = RegExp(r'[0-9]');

/// At least one character that is not a letter or digit (symbol / punctuation).
final _hasSpecial = RegExp(r'[^A-Za-z0-9]');

/// Reason codes returned by [describePasswordProblem].
abstract final class PasswordProblem {
  static const tooShort = 'too_short';
  static const needUpper = 'need_upper';
  static const needLower = 'need_lower';
  static const needDigit = 'need_digit';
  static const needSpecial = 'need_special';
}

bool isStrongPassword(String p) => describePasswordProblem(p) == null;

/// Returns `null` if the password meets policy; otherwise a short machine-readable reason.
String? describePasswordProblem(String p) {
  if (p.length < 8) return PasswordProblem.tooShort;
  if (!_hasUpper.hasMatch(p)) return PasswordProblem.needUpper;
  if (!_hasLower.hasMatch(p)) return PasswordProblem.needLower;
  if (!_hasDigit.hasMatch(p)) return PasswordProblem.needDigit;
  if (!_hasSpecial.hasMatch(p)) return PasswordProblem.needSpecial;
  return null;
}
