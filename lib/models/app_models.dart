import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, resident }

class UserProfile {
  UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.middleInitial,
    required this.suffix,
    required this.role,
    required this.identityKey,
    this.active = true,
  });

  final String uid;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String middleInitial;
  final String suffix;
  final UserRole role;
  final String identityKey;
  final bool active;

  String get fullName {
    final mi = middleInitial.isEmpty ? '' : ' $middleInitial.';
    final suf = suffix.trim().isEmpty ? '' : ' ${suffix.trim()}';
    return '$firstName$mi $lastName$suf'.trim();
  }

  static UserProfile? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return null;
    final roleRaw = (d['role'] as String?) ?? 'resident';
    return UserProfile(
      uid: doc.id,
      email: (d['email'] as String?) ?? '',
      username: (d['username'] as String?) ?? '',
      firstName: (d['firstName'] as String?) ?? '',
      lastName: (d['lastName'] as String?) ?? '',
      middleInitial: (d['middleInitial'] as String?) ?? '',
      suffix: (d['suffix'] as String?) ?? '',
      role: roleRaw == 'admin' ? UserRole.admin : UserRole.resident,
      identityKey: (d['identityKey'] as String?) ?? '',
      active: d['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'middleInitial': middleInitial,
        'suffix': suffix,
        'role': role == UserRole.admin ? 'admin' : 'resident',
        'identityKey': identityKey,
        'active': active,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

String buildIdentityKey({
  required String firstName,
  required String lastName,
  required String middleInitial,
  required String suffix,
}) {
  String norm(String s) => s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  final mi = middleInitial.trim().toUpperCase();
  return '${norm(firstName)}|${norm(lastName)}|${mi.isEmpty ? '-' : mi}|${norm(suffix)}';
}
