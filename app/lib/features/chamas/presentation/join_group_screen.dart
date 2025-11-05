import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;

Future<void> _joinChama() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);
  final user = FirebaseAuth.instance.currentUser;

  try {
    final query = await FirebaseFirestore.instance
        .collection('chamas')
        .where('inviteCode',
            isEqualTo: _codeController.text.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chama not found. Check your invite code.')),
      );
      return;
    }

    final chamaDoc = query.docs.first;
    final chamaId = chamaDoc.id;

    // ✅ Add user to chama members if not already added
    await FirebaseFirestore.instance.collection('chamas').doc(chamaId).update({
      'members': FieldValue.arrayUnion([user!.uid]),
    });

    // ✅ Update user doc to store multiple chama IDs
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userRef.set({
      'chamas': FieldValue.arrayUnion([chamaId])
    }, SetOptions(merge: true));

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${chamaDoc['name']} successfully!')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error joining Chama: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join a Chama')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Enter Invite Code',
                  prefixIcon: Icon(Icons.key),
                ),
                validator: (v) => v!.isEmpty ? 'Enter invite code' : null,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.group_add),
                      onPressed: _joinChama,
                      label: const Text('Join Chama'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
