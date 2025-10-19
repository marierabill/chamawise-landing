import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/data/auth_repository.dart';


final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
return FirebaseAuth.instance;
});


final authRepositoryProvider = Provider<AuthRepository>((ref) {
final auth = ref.read(firebaseAuthProvider);
return AuthRepository(auth);
});


final authStateChangesProvider = StreamProvider<User?>((ref) {
final auth = ref.read(firebaseAuthProvider);
return auth.authStateChanges();
});