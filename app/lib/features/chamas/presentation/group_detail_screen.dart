import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chamawise_app/features/chamas/presentation/edit_group_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final groupRef = FirebaseFirestore.instance.collection('chamas').doc(groupId);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // 🔹 Dynamic Chama Name + Member Count
        title: StreamBuilder<DocumentSnapshot>(
          stream: groupRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Chama Details");
            }
            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final name = data['name'] ?? 'Chama';
            final members = List<String>.from(data['members'] ?? []);
            return Text("$name (${members.length})");
          },
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: groupRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final groupData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final creatorId = groupData['creatorId'];
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;

              if (creatorId == currentUserId) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditChamaScreen(chamaId: groupRef.id),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: groupRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groupData = snapshot.data!.data() as Map<String, dynamic>?;

          if (groupData == null) {
            return const Center(child: Text("Chama not found."));
          }

          final groupName = groupData['name'] ?? 'Unnamed Group';
          final inviteCode = groupData['inviteCode'] ?? '';
          final description = groupData['description'] ?? '';
          final members = List<String>.from(groupData['members'] ?? []);
          final creatorId = groupData['creatorId'];
          final isCreator = creatorId == currentUser?.uid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Group Info
                Text(
                  groupName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  description.isNotEmpty ? description : "No description provided.",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // 🔹 Quick Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Group Overview",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Members:"),
                          Text("${members.length}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Invite Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Invite Code:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(inviteCode,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Members List
                const Text(
                  "Members",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('uid', whereIn: members.isEmpty ? ['dummy'] : members)
                      .snapshots(),
                  builder: (context, membersSnapshot) {
                    if (membersSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = membersSnapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text("No members found."),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final name = data['name'] ?? 'Unnamed';
                        final email = data['email'] ?? '';
                        final photoUrl = data['photoUrl'] ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                            child: photoUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(name),
                          subtitle: Text(email),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                // 🔹 Leave Chama Button (non-creator only)
                if (!isCreator)
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      onPressed: () async {
                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        await groupRef.update({
                          'members': FieldValue.arrayRemove([userId])
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("You left the chama.")),
                        );

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text("Leave Chama"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
