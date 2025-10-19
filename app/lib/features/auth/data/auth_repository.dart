import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_service.dart';



/// Dummy Auth Repository to simulate login/signup behavior
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  // Mock user credentials
  final Map<String, String> _dummyUsers = {
    'test@example.com': 'password123',
    'user@chama.com': 'chama123',
  };

  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay
    if (!_dummyUsers.containsKey(email)) {
      throw Exception('User not found');
    }
    if (_dummyUsers[email] != password) {
      throw Exception('Invalid password');
    }
  }

  Future<void> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_dummyUsers.containsKey(email)) {
      throw Exception('User already exists');
    }
    _dummyUsers[email] = password;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Stream<String?> get authStateChanges async* {
    // Mock auth state stream
    yield null; // initially logged out
  }
}
