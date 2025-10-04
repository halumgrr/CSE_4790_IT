import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              GoRouter.of(context).go('/settings');
            },
          ),
        ],
      ),
      body: const Center(child: Text('All notes will be shown here.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).go('/edit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
