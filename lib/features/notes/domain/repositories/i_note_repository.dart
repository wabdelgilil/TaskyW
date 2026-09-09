import '../../data/models/note_model.dart';

/// واجهة مستودع الملاحظات في طبقة المجال (Domain Layer Interface).
abstract class INoteRepository {
  Future<List<NoteModel>> getNotes({bool includeArchived = false});

  Future<NoteModel?> getNoteById(String id);

  Future<void> insertNote(NoteModel note);

  Future<void> updateNote(NoteModel note);

  Future<void> softDeleteNote(String id);

  Future<List<NoteModel>> getNotesBySyncStatus(String syncStatus);
}
