import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chamawise_app/features/auth/presentation/login_screen.dart';
import 'package:chamawise_app/features/user/presentation/profile_screen.dart';
import 'package:chamawise_app/features/chamas/presentation/create_group_screen.dart';
import 'package:chamawise_app/features/chamas/presentation/join_group_screen.dart';
import 'package:chamawise_app/features/chamas/presentation/group_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    final List<Widget> _tabs = [
      const DashboardTab(),
      const GroupsTab(),
      const WalletTab(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChamaWise"),
        centerTitle: true,
        actions: [
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
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Chamas'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// --------------------
// 🔹 Dashboard Tab
// --------------------
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final name = data['name'] ?? '';
        final email = data['email'] ?? '';
        final photoUrl = data['photoUrl'] ?? '';
        final joinedChamas = List<String>.from(data['chamas'] ?? []);

        final totalChamas = joinedChamas.length;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back,",
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        Text(
                          name.isNotEmpty ? name : email,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 26,
                      backgroundImage:
                          (photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                      child: (photoUrl.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                const Text(
                  'Your Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                _buildInfoCard("Total Chamas", totalChamas.toString()),
                const SizedBox(height: 20),
                _buildInfoCard("Your Contributions", "Ksh 0.00"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --------------------
// 🔹 Groups Tab (Enhanced)
// --------------------
// --------------------
// 🔹 Groups Tab (Enhanced with Group List + Member View)
// --------------------


class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to view your chamas."));
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final joinedGroups = List<String>.from(userData['chamas'] ?? []);

        // 🔹 If user hasn’t joined any chama yet
        if (joinedGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "You haven’t joined a Chama yet!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.group_add),
                  label: const Text("Create a Chama"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                    );
                  },
                  child: const Text("Join using Invite Code"),
                ),
              ],
            ),
          );
        }

        // 🔹 If user already belongs to one or more chamas
        return Scaffold(
          appBar: AppBar(
            title: const Text("My Chamas"),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: "Create Chama",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.key),
                tooltip: "Join via Code",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                  );
                },
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chamas')
                .where(FieldPath.documentId, whereIn: joinedGroups)
                .snapshots(),
            builder: (context, groupSnap) {
              if (!groupSnap.hasData) return const Center(child: CircularProgressIndicator());
              final chamas = groupSnap.data!.docs;

              if (chamas.isEmpty) {
                return const Center(child: Text("No chamas found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chamas.length,
                itemBuilder: (context, index) {
                  final groupData = chamas[index].data() as Map<String, dynamic>;
                  final groupId = chamas[index].id;
                  final name = groupData['name'] ?? 'Unnamed Group';
                  final description = groupData['description'] ?? '';
                  final memberCount = (groupData['members'] as List?)?.length ?? 0;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.groups, color: Colors.white),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "$memberCount members${description.isNotEmpty ? ' • $description' : ''}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupDetailScreen(groupId: groupId),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}


// --------------------
// 🔹 Wallet Tab Placeholder
// --------------------
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Wallet Coming Soon", style: TextStyle(fontSize: 18)),
    );
  }
}
