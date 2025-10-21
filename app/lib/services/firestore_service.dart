import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile(String uid, String email) async {
    final userRef = _db.collection('users').doc(uid);

    final snapshot = await userRef.get();
    if (!snapshot.exists) {
      await userRef.set({
        'uid': uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'name': '', // user can update later
        'chamaMemberships': [],
      });
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
}
