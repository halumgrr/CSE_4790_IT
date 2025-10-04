import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
// ...existing code...
import '../models/note.dart';

class NoteDb {
  static final _store = intMapStoreFactory.store('notes');
  static Database? _db;

  static Future<Database> get _database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/notes.db';
    _db = await databaseFactoryIo.openDatabase(dbPath);
    return _db!;
  }

  static Future<List<Note>> getNotes() async {
    final db = await _database;
    final records = await _store.find(db);
    return records.map((snap) => Note(
      id: snap.key.toString(),
  title: (snap.value['title'] ?? '') as String,
  content: (snap.value['content'] ?? '') as String,
    )).toList();
  }

  static Future<void> addNote(Note note) async {
    final db = await _database;
    await _store.record(int.parse(note.id)).put(db, {
      'title': note.title,
      'content': note.content,
    });
  }

  static Future<void> updateNote(Note note) async {
    final db = await _database;
    await _store.record(int.parse(note.id)).update(db, {
      'title': note.title,
      'content': note.content,
    });
  }

  static Future<void> deleteNote(String id) async {
    final db = await _database;
    await _store.record(int.parse(id)).delete(db);
  }
}
