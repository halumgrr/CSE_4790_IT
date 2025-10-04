import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import 'package:uuid/uuid.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) => NotesNotifier());

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]);

  void addNote(String title, String content) {
    final note = Note(id: const Uuid().v4(), title: title, content: content);
    state = [...state, note];
  }

  void updateNote(String id, String title, String content) {
    state = [
      for (final note in state)
        if (note.id == id)
          Note(id: id, title: title, content: content)
        else
          note
    ];
  }

  Note? getNoteById(String id) {
    try {
      return state.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}
