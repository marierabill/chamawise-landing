import 'package:firebase_auth/firebase_auth.dart';


class AuthRepository {
final FirebaseAuth _auth;
AuthRepository(this._auth);


// Sign up with email
Future<UserCredential> signUpWithEmail(String email, String password) async {
return await _auth.createUserWithEmailAndPassword(email: email, password: password);
}


// Sign in with email
Future<UserCredential> signInWithEmail(String email, String password) async {
return await _auth.signInWithEmailAndPassword(email: email, password: password);
}


// Sign out
Future<void> signOut() async {
await _auth.signOut();
}


User? currentUser() => _auth.currentUser;
}