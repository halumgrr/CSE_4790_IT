import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import 'package:uuid/uuid.dart';
import '../services/note_db.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) => NotesNotifier());

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await NoteDb.getNotes();
    state = notes;
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(id: const Uuid().v4(), title: title, content: content);
    await NoteDb.addNote(note);
    await _loadNotes();
  }

  Future<void> updateNote(String id, String title, String content) async {
    final note = Note(id: id, title: title, content: content);
    await NoteDb.updateNote(note);
    await _loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await NoteDb.deleteNote(id);
    await _loadNotes();
  }

  Note? getNoteById(String id) {
    try {
      return state.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}