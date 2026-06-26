import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class StorageService {
  static const String notesKey = "notes";
  static const String counterKey = "app_counter";

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(notesKey) ?? [];

    return data
        .map(
          (e) => Note.fromJson(
            jsonDecode(e),
          ),
        )
        .toList();
  }

  Future<void> saveNotes(
    List<Note> notes,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      notesKey,
      notes
          .map(
            (e) => jsonEncode(
              e.toJson(),
            ),
          )
          .toList(),
    );
  }

  Future<Map<String, int>> loadCounter() async {
    final prefs = await SharedPreferences.getInstance();

    final data =
        prefs.getString(counterKey);

    if (data == null) {
      return {};
    }

    final map =
        Map<String, dynamic>.from(
      jsonDecode(data),
    );

    return map.map(
      (key, value) => MapEntry(
        key,
        value as int,
      ),
    );
  }

  Future<void> saveCounter(
    Map<String, int> counter,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      counterKey,
      jsonEncode(counter),
    );
  }
}