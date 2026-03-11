import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthController {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _defaultAdminDocId = 'admin';
  static const String _defaultAdminUsername = 'Admin';
  static const String _defaultAdminEmail = 'admin@worksmart.com';
  static const String _defaultAdminPassword = 'admin123';

  AdminAuthController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String _normalizeUsername(String username) => username.trim().toLowerCase();

  String _displayUsername(String username) {
    final usernameKey = _normalizeUsername(username);
    if (usernameKey == _defaultAdminDocId) {
      return _defaultAdminUsername;
    }
    return username.trim();
  }

  String _resolveEmail({required String username, String? fallbackEmail}) {
    final email = fallbackEmail?.trim();
    if (email != null && email.isNotEmpty) {
      return email.toLowerCase();
    }

    final usernameKey = _normalizeUsername(username);
    if (usernameKey == _defaultAdminDocId) {
      return _defaultAdminEmail;
    }

    return '$usernameKey@worksmart.local';
  }

  ///  SEED DEFAULT ADMIN: Creates the default admin
  Future<void> seedDefaultAdmin() async {
    try {
      final docRef = _firestore
          .collection('admin_accounts')
          .doc(_defaultAdminDocId);
      final docSnap = await docRef.get();

      // create if admin ac not exists
      if (!docSnap.exists) {
        await docRef.set({
          'username': _defaultAdminUsername,
          'email': _defaultAdminEmail,
          'user_type': 'admin',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set({
          'username': _defaultAdminUsername,
          'email': _defaultAdminEmail,
          'user_type': 'admin',
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      try {
        await _auth.createUserWithEmailAndPassword(
          email: _defaultAdminEmail,
          password: _defaultAdminPassword,
        );
        await _auth.signOut();
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') {
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        return;
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        return;
      }
    } catch (_) {
      return;
    }
  }

  bool get hasAuthenticatedSession => _auth.currentUser != null;

  bool isAuthenticatedSessionExpired({required Duration maxSessionAge}) {
    final user = _auth.currentUser;
    if (user == null) {
      return true;
    }

    final lastSignInAt = user.metadata.lastSignInTime;
    if (lastSignInAt == null) {
      return false;
    }

    final nowUtc = DateTime.now().toUtc();
    final signedInUtc = lastSignInAt.toUtc();
    return nowUtc.difference(signedInUtc) > maxSessionAge;
  }

  String? getPersistedAdminUsername() {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      final localPart = email.split('@').first.trim();
      if (localPart == _defaultAdminDocId) {
        return _defaultAdminUsername;
      }
      if (localPart.isNotEmpty) {
        return localPart;
      }
    }

    return _defaultAdminUsername;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  ///  VERIFY CREDENTIALS: Check if username and password match Firestore
  Future<bool> verifyAdminCredentials({
    required String username,
    required String password,
  }) async {
    final usernameKey = _normalizeUsername(username);
    try {
      String? profileEmail;

      final docSnap = await _firestore
          .collection('admin_accounts')
          .doc(usernameKey)
          .get();

      if (docSnap.exists) {
        final data = docSnap.data();
        if (data != null && data['user_type'] != 'admin') {
          return false;
        }

        profileEmail = data?['email'] as String?;
      } else if (usernameKey != _defaultAdminDocId) {
        return false;
      }

      final email = _resolveEmail(
        username: username,
        fallbackEmail: profileEmail,
      );
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-credential') {
        return false;
      }
      return false;
    } on FirebaseException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  ///  STORE LOGIN HISTORY: Records when the admin logs in
  Future<void> storeAdminLoginAccount({required String username}) async {
    final now = DateTime.now().toUtc();
    final usernameKey = _normalizeUsername(username);
    final displayUsername = _displayUsername(username);
    final email = _resolveEmail(username: username);

    // Update the main document
    await _firestore.collection('admin_accounts').doc(usernameKey).set({
      'username': displayUsername,
      'email': email,
      'user_type': 'admin',
      'last_login_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'login_count': FieldValue.increment(1),
    }, SetOptions(merge: true));

    // Save history to sub-collection
    await _firestore
        .collection('admin_accounts')
        .doc(usernameKey)
        .collection('login_history')
        .doc(now.millisecondsSinceEpoch.toString())
        .set({
          'username': displayUsername,
          'email': email,
          'user_type': 'admin',
          'logged_in_at': FieldValue.serverTimestamp(),
          'client_logged_in_at': now.toIso8601String(),
        });
  }
}
