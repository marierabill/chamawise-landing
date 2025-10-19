import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_providers.dart';


class RegisterScreen extends ConsumerStatefulWidget {
const RegisterScreen({super.key});
@override
ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends ConsumerState<RegisterScreen> {
final _email = TextEditingController();
final _password = TextEditingController();
bool _loading = false;


Future<void> _register() async {
setState(() => _loading = true);
try {
final repo = ref.read(authRepositoryProvider);
await repo.signUpWithEmail(_email.text.trim(), _password.text.trim());
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
} finally {
setState(() => _loading = false);
}
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Create account')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(children: [
TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
const SizedBox(height: 12),
TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
const SizedBox(height: 20),
ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Create account')),
]),
),
);
}
}