import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> createUserProfile(String uid, String email) async {
    final userRef = _db.collection('users').doc(uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'uid': uid, // ✅ Use uid argument, not user!.uid
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'name': '',
        'chamaMemberships': [],
      });
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
}
