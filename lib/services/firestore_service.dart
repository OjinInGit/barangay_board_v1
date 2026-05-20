import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_constants.dart';
import '../models/announcement.dart';
import '../models/app_models.dart';

class FirestoreService {
  FirestoreService(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      _db.collection('usernames');
  CollectionReference<Map<String, dynamic>> get _identityRegistry =>
      _db.collection('identity_registry');
  CollectionReference<Map<String, dynamic>> get _announcements =>
      _db.collection('announcements');

  Future<String?> emailForUsername(String username) async {
    final key = username.trim().toLowerCase();
    final doc = await _usernames.doc(key).get();
    if (!doc.exists) return null;
    return doc.data()?['email'] as String?;
  }

  Future<UserProfile?> profileForUid(String uid) async {
    final doc = await _users.doc(uid).get();
    return UserProfile.fromDoc(doc);
  }

  Stream<List<UserProfile>> residentsStream() {
    return _users
        .where('role', isEqualTo: 'resident')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map(UserProfile.fromDoc)
          .whereType<UserProfile>()
          .toList();
      list.sort((a, b) => a.fullName.compareTo(b.fullName));
      return list;
    });
  }

  Future<void> updateResidentProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String middleInitial,
    required String suffix,
  }) async {
    final userDoc = await _users.doc(uid).get();
    final oldKey = userDoc.data()?['identityKey'] as String?;
    final newKey = buildIdentityKey(
      firstName: firstName,
      lastName: lastName,
      middleInitial: middleInitial,
      suffix: suffix,
    );
    await _db.runTransaction((tx) async {
      if (oldKey != null && oldKey != newKey) {
        final existing = await tx.get(_identityRegistry.doc(newKey));
        if (existing.exists) {
          final other = existing.data()?['uid'];
          if (other != uid) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'name-taken',
              message: 'Identity already registered',
            );
          }
        }
        tx.delete(_identityRegistry.doc(oldKey));
        tx.set(_identityRegistry.doc(newKey), {'uid': uid});
      }
      tx.update(_users.doc(uid), {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'middleInitial': middleInitial.trim().toUpperCase(),
        'suffix': suffix.trim(),
        'identityKey': newKey,
      });
    });
  }

  Future<void> softDeleteResident({
    required String uid,
    required String username,
  }) async {
    final userDoc = await _users.doc(uid).get();
    final identityKey = userDoc.data()?['identityKey'] as String?;
    final batch = _db.batch();
    batch.update(_users.doc(uid), {'active': false});
    batch.delete(_usernames.doc(username.trim().toLowerCase()));
    if (identityKey != null && identityKey.isNotEmpty) {
      batch.delete(_identityRegistry.doc(identityKey));
    }
    await batch.commit();
  }

  Future<void> registerResident({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String middleInitial,
    required String suffix,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    final identityKey = buildIdentityKey(
      firstName: firstName,
      lastName: lastName,
      middleInitial: middleInitial,
      suffix: suffix,
    );
    final userLower = username.trim().toLowerCase();
    try {
      await _db.runTransaction((tx) async {
        final usernameDoc = await tx.get(_usernames.doc(userLower));
        if (usernameDoc.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'username-taken',
            message: 'Username taken',
          );
        }
        final identityDoc = await tx.get(_identityRegistry.doc(identityKey));
        if (identityDoc.exists) {
          final other = identityDoc.data()?['uid'];
          if (other != uid) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'name-taken',
              message: 'Name taken',
            );
          }
        }
        final profile = UserProfile(
          uid: uid,
          email: email.trim(),
          username: username.trim(),
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          middleInitial: middleInitial.trim().toUpperCase(),
          suffix: suffix.trim(),
          role: UserRole.resident,
          identityKey: identityKey,
        );
        tx.set(_users.doc(uid), profile.toMap());
        tx.set(_usernames.doc(userLower), {
          'uid': uid,
          'email': email.trim(),
        });
        tx.set(_identityRegistry.doc(identityKey), {'uid': uid});
      });
    } catch (e) {
      await cred.user?.delete();
      rethrow;
    }
  }

  /// Marks announcements older than [AppConstants.archiveAfterDays] as archived.
  Future<void> runAutoArchive() async {
    final cutoff = DateTime.now().subtract(
      Duration(days: AppConstants.archiveAfterDays),
    );
    final snap = await _announcements
        .orderBy('createdAt', descending: true)
        .limit(300)
        .get();
    final batch = _db.batch();
    var count = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['archived'] == true) continue;
      final created = (data['createdAt'] as Timestamp?)?.toDate();
      if (created != null && created.isBefore(cutoff)) {
        batch.update(doc.reference, {
          'archived': true,
          'archivedAt': FieldValue.serverTimestamp(),
        });
        count++;
        if (count >= 400) break;
      }
    }
    if (count > 0) await batch.commit();
  }

  Stream<List<AnnouncementModel>> _allAnnouncementsStream() {
    return _announcements.orderBy('createdAt', descending: true).snapshots().asyncMap(
      (snap) async {
        await runAutoArchive();
        return snap.docs.map(AnnouncementModel.fromDoc).toList();
      },
    );
  }

  Stream<List<AnnouncementModel>> announcementsStream() {
    return _allAnnouncementsStream().map((list) {
      final active = list.where((a) => !a.archived).toList(growable: true);
      active.sort(compareAnnouncementsBySeverity);
      return active;
    });
  }

  Stream<List<AnnouncementModel>> announcementsArchivedStream() {
    return _allAnnouncementsStream().map((list) {
      final archived = list.where((a) => a.archived).toList(growable: true);
      archived.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return archived;
    });
  }

  Stream<List<AnnouncementModel>> announcementsForResident() {
    return announcementsStream();
  }

  Future<String> createAnnouncement(AnnouncementModel model) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    final ref = await _announcements.add(model.toMap(uid));
    return ref.id;
  }

  Future<void> updateAnnouncement(AnnouncementModel model) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    await _announcements.doc(model.id).update(model.toUpdateMap());
  }

  Future<void> archiveAnnouncement(String id) async {
    await _announcements.doc(id).update({
      'archived': true,
      'archivedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAnnouncement(String id) async {
    await _announcements.doc(id).delete();
  }

  Future<void> updateFcmToken(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _users.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
  }
}
