import 'package:flutter/material.dart';

class NoteEditScreen extends StatelessWidget {
  const NoteEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create/Edit Note')),
      body: const Center(child: Text('Note title and content fields go here.')),
    );
  }
}
