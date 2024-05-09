import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ModToolScreen extends ConsumerWidget {
  final String name;
  const ModToolScreen({required this.name, super.key});

  void navigateToEditScreen(context) {
    Routemaster.of(context).push('/r/$name/edit-community');
  }

  void navigateToAddModsScreen(context) {
    Routemaster.of(context).push('/r/$name/mod-tools/add-mods');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Tools"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text("Add Moderators"),
            onTap: () => navigateToAddModsScreen(context),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Community"),
            onTap: () => navigateToEditScreen(context),
          )
        ],
      ),
    );
  }
}
