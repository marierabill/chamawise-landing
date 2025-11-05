import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _loading = false;

  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

Future<void> _createChama() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);
  final user = FirebaseAuth.instance.currentUser;
  final inviteCode = generateInviteCode();

  final chamaRef = FirebaseFirestore.instance.collection('chamas').doc();

  // Create chama document
  await chamaRef.set({
    'id': chamaRef.id,
    'name': _nameController.text.trim(),
    'description': _descController.text.trim(),
    'creatorId': user!.uid,
    'members': [user.uid],
    'inviteCode': inviteCode,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // 🔥 Update user doc to store multiple chama IDs
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  await userRef.set({
    'chamas': FieldValue.arrayUnion([chamaRef.id])
  }, SetOptions(merge: true));

  if (mounted) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chama created successfully!')),
    );
    Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a Chama')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Chama Name'),
                validator: (v) => v!.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createChama,
                      child: const Text('Create Chama'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
