import 'package:flutter/material.dart';
import 'package:chamawise_app/features/groups/presentation/create_group_screen.dart';
import 'package:chamawise_app/features/groups/presentation/join_group_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: const Text("Your Chama Groups")),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'create') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()));
          } else if (value == 'join') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const JoinGroupScreen()));
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'create', child: Text("Create Chama")),
          const PopupMenuItem(value: 'join', child: Text("Join Chama")),
        ],
        child: const FloatingActionButton(
          child: Icon(Icons.group_add),
        ),
      ),
    );
  }
}
