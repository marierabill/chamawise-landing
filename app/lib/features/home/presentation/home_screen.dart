import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chamawise_app/features/auth/presentation/login_screen.dart';
import 'package:chamawise_app/features/user/presentation/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? profileData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      profileData = doc.data();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChamaWise Home"),
        actions: [
          // 👤 Profile Button with Avatar
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => fetchProfile());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (profileData?['profileImageUrl'] != null &&
                        (profileData!['profileImageUrl'] as String).isNotEmpty)
                    ? NetworkImage(profileData!['profileImageUrl'])
                    : null,
                child: (profileData?['profileImageUrl'] == null ||
                        (profileData!['profileImageUrl'] as String).isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: profileData == null
            ? const Text("No profile data found.")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: (profileData?['profileImageUrl'] != null &&
                            (profileData!['profileImageUrl'] as String).isNotEmpty)
                        ? NetworkImage(profileData!['profileImageUrl'])
                        : null,
                    child: (profileData?['profileImageUrl'] == null ||
                            (profileData!['profileImageUrl'] as String).isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Welcome, ${profileData!['name']?.isNotEmpty == true ? profileData!['name'] : 'User'}!",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Email: ${profileData!['email'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}
