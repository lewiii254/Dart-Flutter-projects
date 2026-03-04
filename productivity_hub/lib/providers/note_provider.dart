import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NoteProvider extends ChangeNotifier {
  static const _notesKey = 'notes_data';

  NoteProvider() {
    _loadNotes();
  }

  final List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);
  int get totalNotes => _notes.length;

  Future<void> addNote({required String title, required String content}) async {
    final note = Note(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      timestamp: DateTime.now(),
    );

    _notes.insert(0, note);
    notifyListeners();
    await _saveNotes();
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index == -1) {
      return;
    }

    _notes[index] = _notes[index].copyWith(
      title: title,
      content: content,
      timestamp: DateTime.now(),
    );
    notifyListeners();
    await _saveNotes();
  }

  Future<void> removeNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
    await _saveNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_notesKey);
    if (encoded == null || encoded.isEmpty) {
      return;
    }

    final rawList = jsonDecode(encoded) as List<dynamic>;
    _notes
      ..clear()
      ..addAll(
        rawList.map((item) => Note.fromMap(item as Map<String, dynamic>)),
      );
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _notes.map((note) => note.toMap()).toList();
    await prefs.setString(_notesKey, jsonEncode(rawList));
  }
}
