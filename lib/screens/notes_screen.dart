import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController controller = TextEditingController();

  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final data = notes
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(
      'launcher_notes',
      data,
    );
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final data =
        prefs.getStringList('launcher_notes') ?? [];

    setState(() {
      notes = data
          .map(
            (e) => Note.fromJson(
              jsonDecode(e),
            ),
          )
          .toList();
    });
  }

  void addNote() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      notes.add(
        Note(
          text: text,
          done: false,
        ),
      );
    });

    controller.clear();

    saveNotes();
  }

  void toggleNote(int index) {
    setState(() {
      notes[index].done =
          !notes[index].done;
    });

    saveNotes();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });

    saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Tambah catatan...",
                      hintStyle:
                          TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addNote,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder:
                  (context, index) {
                final note =
                    notes[index];

                return ListTile(
                  leading: Checkbox(
                    value: note.done,
                    onChanged: (_) {
                      toggleNote(index);
                    },
                  ),
                  title: Text(
                    note.text,
                    style: TextStyle(
                      color:
                          Colors.white,
                      decoration:
                          note.done
                              ? TextDecoration
                                  .lineThrough
                              : null,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      deleteNote(
                        index,
                      );
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}