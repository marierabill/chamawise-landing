import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditChamaScreen extends StatefulWidget {
  final String chamaId;
  const EditChamaScreen({required this.chamaId, super.key});

  @override
  State<EditChamaScreen> createState() => _EditChamaScreenState();
}

class _EditChamaScreenState extends State<EditChamaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _loading = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadChama();
  }

  Future<void> _loadChama() async {
    final doc = await FirebaseFirestore.instance.collection('chamas').doc(widget.chamaId).get();
    if (doc.exists) {
      _nameController.text = doc['name'] ?? '';
      _descController.text = doc['description'] ?? '';
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final chamaRef = FirebaseFirestore.instance.collection('chamas').doc(widget.chamaId);
    final doc = await chamaRef.get();

    // 🔒 Ensure only the creator can edit
    if (doc['creatorId'] != user?.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only the creator can edit this chama')),
      );
      setState(() => _loading = false);
      return;
    }

    await chamaRef.update({
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chama details updated')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Chama')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Chama Name'),
                validator: (val) => val!.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _saveChanges,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
