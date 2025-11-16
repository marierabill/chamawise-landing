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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contributions - ${widget.chamaName}"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chamas')
            .doc(widget.chamaId)
            .collection('contributions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No contributions found."));
          }

          final contributions = snapshot.data!.docs;
          if (contributions.isEmpty) {
            return _buildEmptyState(context);
          }

          // Group totals by user
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(totalContributions),
                const SizedBox(height: 20),

                const Text(
                  "Member Contributions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

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
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!userSnapshot.hasData) {
                        return const Center(
                            child: Text("Unable to load member data."));
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
                              "User";
                          final photoUrl = userData['photoUrl'] ?? '';

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl.isEmpty
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
                                  uid, displayName, photoUrl),
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
        label: const Text("Add Contribution"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(double totalContributions) {
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
          Text(
            "Ksh ${totalContributions.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payments_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "No contributions recorded yet.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Your First Contribution"),
              onPressed: _showAddContributionDialog,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddContributionDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Contribution"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Amount (Ksh)"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Description (optional)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _addContribution,
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addContribution() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || double.tryParse(amountText) == null) return;

    setState(() => isLoading = true);

    final amount = double.parse(amountText);
    final desc = _descController.text.trim();

    try {
      await FirebaseFirestore.instance
          .collection('chamas')
          .doc(widget.chamaId)
          .collection('contributions')
          .add({
        'userId': user!.uid,
        'amount': amount,
        'description': desc,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contribution added successfully")),
        );
      }

      _amountController.clear();
      _descController.clear();
    } catch (e) {
      debugPrint("Error adding contribution: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showUserContributions(
      String userId, String userName, String photo) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chamas')
              .doc(widget.chamaId)
              .collection('contributions')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: photo.isNotEmpty
                              ? NetworkImage(photo)
                              : null,
                          child: photo.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "$userName’s Contributions",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("No contributions yet.",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            final docs = snapshot.data!.docs;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: photo.isNotEmpty
                              ? NetworkImage(photo)
                              : null,
                          child: photo.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "$userName’s Contributions",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    ...docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final amount = (data['amount'] ?? 0).toDouble();
                      final desc = data['description'] ?? '';
                      final time = data['timestamp'] != null
                          ? DateFormat('MMM d, y h:mm a')
                              .format((data['timestamp'] as Timestamp).toDate())
                          : 'Pending';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.attach_money,
                              color: Colors.green),
                          title: Text(
                            "Ksh ${amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text(desc.isNotEmpty ? "$desc • $time" : time),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
