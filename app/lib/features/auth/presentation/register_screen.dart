import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_service.dart'; // ✅ FIXED
import '../data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chamawise_app/services/firestore_service.dart';
import 'package:chamawise_app/features/home/presentation/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;

	Future<void> _register() async {
	  setState(() => _loading = true);
	  try {
		await _auth.createUserWithEmailAndPassword(
		  email: _email.text.trim(),
		  password: _password.text.trim(),
		);
		
		final user = FirebaseAuth.instance.currentUser;
		if (user != null) {
		  await FirestoreService().createUserProfile(user.uid, user.email!);
		}
		
		Navigator.pushReplacement(
		  context,
		  MaterialPageRoute(builder: (_) => const HomeScreen()),
		);
	  } on FirebaseAuthException catch (e) {
		debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
		ScaffoldMessenger.of(context).showSnackBar(
		  SnackBar(content: Text(e.message ?? 'Registration failed')),
		);
	  } catch (e) {
		debugPrint("Unknown error: $e");
		ScaffoldMessenger.of(context).showSnackBar(
		  const SnackBar(content: Text('An unknown error occurred.')),
		);
	  } finally {
		setState(() => _loading = false);
	  }
	}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}
