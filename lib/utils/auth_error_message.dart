import 'package:firebase_auth/firebase_auth.dart';

import '../l10n/app_strings.dart';

/// Maps Firebase Auth errors to localized snackbar text.
String authErrorMessage(AppStrings s, FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return s.errInvalidEmail;
    case 'user-disabled':
      return s.errUserDisabled;
    case 'user-not-found':
      return s.errUserNotFound;
    case 'wrong-password':
      return s.errWrongPassword;
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return s.errInvalidCredentials;
    case 'email-already-in-use':
      return s.errEmailInUse;
    case 'weak-password':
      return s.errWeakPasswordAuth;
    case 'operation-not-allowed':
      return s.errOperationNotAllowed;
    case 'too-many-requests':
      return s.errTooManyRequests;
    case 'network-request-failed':
      return s.errNetwork;
    default:
      return s.errAuthWithDetail(e.code);
  }
}
