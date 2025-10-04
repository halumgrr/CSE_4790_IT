import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/note_provider.dart';
import '../providers/font_size_provider.dart';

class NoteEditScreen extends ConsumerStatefulWidget {
  const NoteEditScreen({super.key});

  @override
  ConsumerState<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends ConsumerState<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? editingNoteId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = GoRouterState.of(context).uri.queryParameters['id'];
    if (id != null && editingNoteId != id) {
      final note = ref.read(notesProvider.notifier).getNoteById(id);
      if (note != null) {
        _titleController.text = note.title;
        _contentController.text = note.content;
        editingNoteId = id;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;
    if (editingNoteId != null) {
      ref.read(notesProvider.notifier).updateNote(editingNoteId!, title, content);
    } else {
      ref.read(notesProvider.notifier).addNote(title, content);
    }
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(fontSizeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editingNoteId != null ? 'Edit Note' : 'Create Note',
          style: TextStyle(fontSize: fontSize),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', labelStyle: TextStyle(fontSize: fontSize)),
              style: TextStyle(fontSize: fontSize),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content', labelStyle: TextStyle(fontSize: fontSize)),
                maxLines: null,
                expands: true,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
