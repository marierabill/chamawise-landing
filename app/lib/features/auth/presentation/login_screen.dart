import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../providers/auth_providers.dart';
import 'register_screen.dart';


class LoginScreen extends ConsumerStatefulWidget {
const LoginScreen({super.key});
@override
ConsumerState<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends ConsumerState<LoginScreen> {
final _email = TextEditingController();
final _password = TextEditingController();
bool _loading = false;


Future<void> _login() async {
setState(() => _loading = true);
try {
final repo = ref.read(authRepositoryProvider);
await repo.signInWithEmail(_email.text.trim(), _password.text.trim());
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
} finally {
setState(() => _loading = false);
}
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Sign in')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(children: [
TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
const SizedBox(height: 12),
TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
const SizedBox(height: 20),
ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Sign in')),
const SizedBox(height: 12),
TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Create account')),
]),
),
);
}
}