import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firebase_service.dart';


class OnboardingScreen extends ConsumerStatefulWidget {
const OnboardingScreen({super.key});
@override
ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}


class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
final _name = TextEditingController();
final _goal = TextEditingController();
final _joinCode = TextEditingController();
final _firebase = FirebaseService();
bool _loading = false;


Future<void> _createChama() async {
setState(() => _loading = true);
try {
final doc = await _firebase.createChama({
'name': _name.text.trim(),
'createdAt': DateTime.now(),
'goal': {'amount': int.tryParse(_goal.text) ?? 0},
});
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chama created: \${doc.id}')));
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
} finally {
setState(() => _loading = false);
}
}


Future<void> _joinChama() async {
// For sprint 1, joining by code is a placeholder; implement secure join later
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join flow is coming soon')));
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Welcome')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: SingleChildScrollView(
child: Column(children: [
const Text('Create a new chama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
TextField(controller: _name, decoration: const InputDecoration(labelText: 'Chama name')),
const SizedBox(height: 8),
TextField(controller: _goal, decoration: const InputDecoration(labelText: 'Goal amount'), keyboardType: TextInputType.number),
const SizedBox(height: 12),
ElevatedButton(onPressed: _loading ? null : _createChama, child: _loading ? const CircularProgressIndicator() : const Text('Create Chama')),
const Divider(height: 40),
const Text('Or join an existing chama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
TextField(controller: _joinCode, decoration: const InputDecoration(labelText: 'Invite code')),
const SizedBox(height: 12),
ElevatedButton(onPressed: _joinChama, child: const Text('Join Chama')),
]),
),
),
);
}
}