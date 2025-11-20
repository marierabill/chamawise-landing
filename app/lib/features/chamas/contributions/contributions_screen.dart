import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ContributionsScreen extends StatefulWidget {
  final String chamaId;
  final String chamaName;
  final bool isCreator;

  const ContributionsScreen({
    super.key,
    required this.chamaId,
    required this.chamaName,
    required this.isCreator,
  });

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedUserForCreator;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contributions - ${widget.chamaName}")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chamas')
            .doc(widget.chamaId)
            .collection('contributions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final contributions = snapshot.data!.docs;

          if (contributions.isEmpty) {
            return _buildEmptyState(context);
          }

          // ---- Compute totals per user ----
          Map<String, double> userTotals = {};
          for (var doc in contributions) {
            final data = doc.data() as Map<String, dynamic>;
            final uid = data['userId'];
            final amount = (data['amount'] ?? 0).toDouble();

            userTotals[uid] = (userTotals[uid] ?? 0) + amount;
          }

          final totalContributions =
              userTotals.values.fold(0.0, (a, b) => a + b);

          final involvedUserIds = userTotals.keys.toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(totalContributions),
                const SizedBox(height: 20),

                const Text("Member Contributions",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Fetch user profiles
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where(
                          FieldPath.documentId,
                          whereIn: involvedUserIds.isEmpty
                              ? ["placeholder"]
                              : involvedUserIds,
                        )
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final userDocs = {
                        for (var doc in userSnapshot.data!.docs)
                          doc.id: (doc.data() as Map<String, dynamic>)
                      };

                      return ListView.builder(
                        itemCount: userTotals.length,
                        itemBuilder: (context, index) {
                          final uid = userTotals.keys.elementAt(index);
                          final total = userTotals[uid] ?? 0;
                          final userData = userDocs[uid] ?? {};

                          final displayName = userData['name'] ??
                              userData['email'] ??
                              "Member";

                          final photo = userData['photoUrl'] ?? '';

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                backgroundImage: photo.isNotEmpty
                                    ? NetworkImage(photo)
                                    : null,
                                child: photo.isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.green)
                                    : null,
                              ),
                              title: Text(displayName),
                              subtitle: Text(
                                "Ksh ${total.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                              onTap: () => _showUserContributions(
                                uid,
                                displayName,
                                photo,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContributionDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Contribution"),
      ),
    );
  }

  // ------------------- SUMMARY BOX -----------------------
  Widget _buildSummaryCard(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Contributions", style: TextStyle(fontSize: 16)),
          Text("Ksh ${total.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ------------------- EMPTY STATE -----------------------
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payments_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("No contributions recorded yet.",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add First Contribution"),
              onPressed: _showAddContributionDialog,
            ),
          ],
        ),
      ),
    );
  }

// ------------------- ADD CONTRIBUTION (ROLE-AWARE) -----------------------
Future<void> _showAddContributionDialog() async {
  List<Map<String, dynamic>> membersList = [];

  if (widget.isCreator) {
    // 🔥 Fetch the chama document (contains the members array)
    final chamaDoc = await FirebaseFirestore.instance
        .collection('chamas')
        .doc(widget.chamaId)
        .get();

    // 🔥 Extract array of member IDs
    List<String> memberIds =
        List<String>.from(chamaDoc.data()?['members'] ?? []);

    if (memberIds.isNotEmpty) {
      // 🔥 Fetch user documents based on array
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: memberIds)
          .get();

      membersList = usersSnap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "name": data["name"] ?? "Unnamed",
          "email": data["email"] ?? "",
          "photoUrl": data["photoUrl"] ?? "",
        };
      }).toList();
    }
  }

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
              widget.isCreator
                  ? "Log a Contribution"
                  : "Add Your Contribution",
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isCreator) ...[
                    membersList.isEmpty
                        ? const Text(
                            "No members found.\nAdd members to this chama first.",
                            style: TextStyle(color: Colors.red),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedUserForCreator,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: "Select Member",
                            ),
                            items: membersList
                                .map<DropdownMenuItem<String>>((m) {
                              return DropdownMenuItem<String>(
                                value: m["id"],
                                child: Text(
                                  m["name"] ?? m["email"] ?? "Member",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              setStateDialog(() {
                                _selectedUserForCreator = v;
                              });
                            },
                          ),

                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount (Ksh)"),
                  ),

                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Add"),
                onPressed: membersList.isEmpty && widget.isCreator
                    ? null
                    : _addContribution,
              ),
            ],
          );
        },
      );
    },
  );
}




  Future<void> _addContribution() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null) return;

    final desc = _descController.text.trim();

    String uidToLog = user!.uid;

    if (widget.isCreator) {
      if (_selectedUserForCreator == null) return;
      uidToLog = _selectedUserForCreator!;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('chamas')
          .doc(widget.chamaId)
          .collection('contributions')
          .add({
        'userId': uidToLog,
        'amount': amount,
        'description': desc,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contribution added")),
        );
      }

      _amountController.clear();
      _descController.clear();
      _selectedUserForCreator = null;
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ------------------- MEMBER HISTORY -----------------------
  Future<void> _showUserContributions(
      String uid, String userName, String photo) async {
    final stream = FirebaseFirestore.instance
        .collection('chamas')
        .doc(widget.chamaId)
        .collection('contributions')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();

    List<DocumentSnapshot> cache = [];
    bool loaded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(builder: (context, setSheet) {
          return StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData && !loaded) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData && !loaded) {
                cache = snapshot.data!.docs;
                loaded = true;
              }

              final docs =
                  snapshot.data?.docs.isNotEmpty == true
                      ? snapshot.data!.docs
                      : cache;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage:
                              photo.isNotEmpty ? NetworkImage(photo) : null,
                          child: photo.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text("$userName’s Contributions",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: docs.isEmpty
                          ? const Center(
                              child: Text("No contributions yet"),
                            )
                          : ListView(
                              children: docs.map((doc) {
                                final data =
                                    doc.data() as Map<String, dynamic>;
                                final amt =
                                    (data['amount'] ?? 0).toDouble();
                                final desc = data['description'] ?? '';
                                final ts = data['timestamp'];

                                final time = ts is Timestamp
                                    ? DateFormat('MMM d, h:mm a')
                                        .format(ts.toDate())
                                    : 'Pending';

                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.money,
                                        color: Colors.green),
                                    title: Text(
                                        "Ksh ${amt.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(desc.isEmpty
                                        ? time
                                        : "$desc • $time"),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }
}
