import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository_impl.dart';

/// متحكم الملاحظات العامة: تحميل، حفظ، تثبيت، أرشفة، حذف، وبحث لحظي.
class NotesController extends ChangeNotifier {
  NotesController({INoteRepository? repository})
      : _repository = repository ?? NoteRepositoryImpl();

  final INoteRepository _repository;
  final Uuid _uuid = const Uuid();

  List<NoteModel> _notes = <NoteModel>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';

  List<NoteModel> get notes => List.unmodifiable(_notes);
  List<NoteModel> get visibleNotes {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _notes;
    return _notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            (n.content?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  List<NoteModel> get pinnedNotes =>
      visibleNotes.where((n) => n.isPinned).toList();
  List<NoteModel> get normalNotes =>
      visibleNotes.where((n) => !n.isPinned).toList();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _notes = await _repository.getNotes();
    } catch (e) {
      _errorMessage = 'تعذر تحميل الملاحظات';
      debugPrint('[NotesController] load: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<NoteModel?> add({
    required String title,
    String? content,
    String? colorHex,
  }) async {
    _errorMessage = null;
    final now = DateTime.now().toUtc();
    final note = NoteModel(
      id: _uuid.v4(),
      title: title.trim().isEmpty ? 'ملاحظة جديدة' : title.trim(),
      content: content,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _repository.insertNote(note);
      _notes = [note, ..._notes];
      notifyListeners();
      return note;
    } catch (e) {
      _errorMessage = 'تعذر حفظ الملاحظة';
      debugPrint('[NotesController] add: $e');
      notifyListeners();
      return null;
    }
  }

  Future<bool> update({
    required String id,
    String? title,
    String? content,
    String? colorHex,
  }) async {
    try {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index < 0) return false;
      final current = _notes[index];
      final updated = current.copyWith(
        title: title ?? current.title,
        content: content ?? current.content,
        colorHex: colorHex ?? current.colorHex,
      );
      await _repository.updateNote(updated);
      final next = [..._notes];
      next[index] = updated;
      _notes = next;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'تعذر تحديث الملاحظة';
      debugPrint('[NotesController] update: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setPinned(String id, bool pinned) async {
    try {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index < 0) return false;
      final current = _notes[index];
      final updated = current.copyWith(isPinned: pinned);
      await _repository.updateNote(updated);
      final next = [..._notes];
      next[index] = updated;
      _notes = next;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[NotesController] setPinned: $e');
      return false;
    }
  }

  Future<bool> setArchived(String id, bool archived) async {
    try {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index < 0) return false;
      final current = _notes[index];
      final updated = current.copyWith(isArchived: archived);
      await _repository.updateNote(updated);
      final next = [..._notes];
      if (archived) {
        next.removeAt(index);
      } else {
        next[index] = updated;
      }
      _notes = next;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[NotesController] setArchived: $e');
      return false;
    }
  }

  Future<bool> remove(String id) async {
    try {
      await _repository.softDeleteNote(id);
      _notes = _notes.where((n) => n.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'تعذر حذف الملاحظة';
      debugPrint('[NotesController] remove: $e');
      notifyListeners();
      return false;
    }
  }
}