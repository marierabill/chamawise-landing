import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chamawise_app/features/auth/presentation/login_screen.dart';
import 'package:chamawise_app/features/user/presentation/profile_screen.dart';
import 'package:chamawise_app/features/chamas/presentation/create_group_screen.dart';
import 'package:chamawise_app/features/chamas/presentation/join_group_screen.dart';
import 'package:chamawise_app/features/chamas/presentation/group_detail_screen.dart';
import 'package:chamawise_app/features/chamas/contributions/contributions_screen.dart';


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
// 🔹 Dashboard Tab (Auto-updating Contributions)
// --------------------
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final name = data['name'] ?? '';
        final email = data['email'] ?? '';
        final photoUrl = data['photoUrl'] ?? '';
        final joinedChamas = List<String>.from(data['chamas'] ?? []);
        final totalChamas = joinedChamas.length;

        // 🔹 Watch user contributions in all joined chamas
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('contributions')
              .where('userId', isEqualTo: user!.uid)
              .snapshots(),
          builder: (context, contributionsSnap) {
            if (contributionsSnap.hasError) {
              return Center(child: Text('Error: ${contributionsSnap.error}'));
            }

            if (contributionsSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = contributionsSnap.data?.docs ?? [];
            double totalContributions = 0.0;

            for (var doc in docs) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                final rawAmount = data['amount'];

                if (rawAmount is int) {
                  totalContributions += rawAmount.toDouble();
                } else if (rawAmount is double) {
                  totalContributions += rawAmount;
                } else if (rawAmount is String) {
                  totalContributions += double.tryParse(rawAmount) ?? 0.0;
                }
              } catch (e) {
                debugPrint('Contribution parse error: $e');
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: SingleChildScrollView(
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
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                name.isNotEmpty ? name : email,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),

                      _buildInfoCard("Total Chamas", totalChamas.toString()),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        "Your Contributions",
                        "Ksh ${totalContributions.toStringAsFixed(2)}",
                      ),

                      const SizedBox(height: 30),

                      // 🔹 Navigate to ContributionsScreen
                      ElevatedButton.icon(
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text("View All Contributions"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        onPressed: () async {
                          await _handleContributionsNavigation(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleContributionsNavigation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final joinedChamas = List<String>.from(userData['chamas'] ?? []);

    if (joinedChamas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You haven't joined any chama yet.")),
      );
      return;
    }

    final List<Map<String, dynamic>> chamaList = [];
    for (String chamaId in joinedChamas) {
      final chamaDoc = await FirebaseFirestore.instance
          .collection('chamas')
          .doc(chamaId)
          .get();

      if (chamaDoc.exists) {
        final data = chamaDoc.data()!;
        chamaList.add({
          'id': chamaId,
          'name': data['name'] ?? 'Unnamed Chama',
          'creatorId': data['creatorId'] ?? '',
        });
      }
    }

    String? selectedChamaId;
    await showDialog(
      context: context,
      builder: (context) {
        String? tempSelection;

        return AlertDialog(
          title: const Text('Select a Chama'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Choose a Chama",
                ),
                value: tempSelection,
                items: chamaList.map((chama) {
                  return DropdownMenuItem<String>(
                    value: chama['id'],
                    child: Text(chama['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => tempSelection = value);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (tempSelection != null) {
                  selectedChamaId = tempSelection;
                  Navigator.pop(context);
                }
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );

    if (selectedChamaId == null) return;

    final selectedChama =
        chamaList.firstWhere((c) => c['id'] == selectedChamaId);
    final isCreator = selectedChama['creatorId'] == user!.uid;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContributionsScreen(
          chamaId: selectedChama['id'],
          chamaName: selectedChama['name'],
          isCreator: isCreator,
        ),
      ),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}



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

    final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final joinedGroups = List<String>.from(userData['chamas'] ?? []);

        // 🔹 Empty State: No chama joined or created yet
        if (joinedGroups.isEmpty) {
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
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.groups_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      "You haven’t joined any chama yet!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
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
              ),
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
          body: FutureBuilder<List<DocumentSnapshot>>(
            // ✅ Firestore `whereIn` has a limit of 10. Split if needed.
            future: _fetchUserChamas(joinedGroups),
            builder: (context, groupSnap) {
              if (groupSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final chamas = groupSnap.data ?? [];

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
                  final creatorId = groupData['creatorId'] ?? '';
                  final isCreator = creatorId == user!.uid;

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
                      trailing: isCreator
                          ? const Icon(Icons.star, color: Colors.orange)
                          : const Icon(Icons.arrow_forward_ios, size: 18),
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

  /// 🔹 Handles Firestore whereIn limitations (max 10)
  Future<List<DocumentSnapshot>> _fetchUserChamas(List<String> joinedGroups) async {
    final List<DocumentSnapshot> allDocs = [];
    const int batchSize = 10;

    for (int i = 0; i < joinedGroups.length; i += batchSize) {
      final subList = joinedGroups.sublist(
        i,
        i + batchSize > joinedGroups.length ? joinedGroups.length : i + batchSize,
      );

      final querySnap = await FirebaseFirestore.instance
          .collection('chamas')
          .where(FieldPath.documentId, whereIn: subList)
          .get();

      allDocs.addAll(querySnap.docs);
    }
    return allDocs;
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
