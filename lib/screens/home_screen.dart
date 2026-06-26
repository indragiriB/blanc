import 'dart:async';

import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/storage_service.dart';
import 'app_drawer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService storage = StorageService();
Map<String, int> appCounter = {};
  final TextEditingController noteController =
      TextEditingController();

  List<Note> notes = [];

  late Timer timer;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
loadCounter();
    loadNotes();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          now = DateTime.now();
        });
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    noteController.dispose();
    super.dispose();
  }
  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  loadCounter();
}
Future<void> loadCounter() async {
  final counter =
      await storage.loadCounter();

  setState(() {
    appCounter = counter;
  });
}
  Future<void> loadNotes() async {
    final loadedNotes =
        await storage.loadNotes();

    setState(() {
      notes = loadedNotes;
    });
  }

  Future<void> addNote() async {
    final text =
        noteController.text.trim();

    if (text.isEmpty) return;

    notes.add(
      Note(
        text: text,
        done: false,
      ),
    );

    await storage.saveNotes(notes);

    noteController.clear();

    setState(() {});
  }

  Future<void> toggleNote(
    int index,
  ) async {
    notes[index].done =
        !notes[index].done;

    await storage.saveNotes(notes);

    setState(() {});
  }

  Future<void> deleteNote(
    int index,
  ) async {
    notes.removeAt(index);

    await storage.saveNotes(notes);

    setState(() {});
  }

  String getMonth(int month) {
    const months = [
      "",
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];

    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) <
            -200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AppDrawerScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight:
                        FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${now.day} ${getMonth(now.month)} ${now.year}",
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                const Divider(
                  color: Colors.white12,
                ),

                const SizedBox(height: 10),

                const Text(
                  "📝 CATATAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller:
                            noteController,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                        ),
                        decoration:
                            InputDecoration(
                          hintText:
                              "Tambah catatan...",
                          hintStyle:
                              const TextStyle(
                            color:
                                Colors.grey,
                          ),
                          filled: true,
                          fillColor:
                              Colors.white10,
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        width: 10),

                    IconButton(
                      onPressed:
                          addNote,
                      icon: const Icon(
                        Icons.add,
                        color:
                            Colors.white,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                if (notes.isEmpty)
                  const Text(
                    "Belum ada catatan",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                ...List.generate(
                  notes.length,
                  (index) {
                    final note =
                        notes[index];

                    return Card(
                      color:
                          Colors.white10,
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(
                        leading:
                            Checkbox(
                          value:
                              note.done,
                          onChanged:
                              (_) {
                            toggleNote(
                                index);
                          },
                        ),
                        title: Text(
                          note.text,
                          style:
                              TextStyle(
                            color: Colors
                                .white,
                            decoration:
                                note.done
                                    ? TextDecoration
                                        .lineThrough
                                    : null,
                          ),
                        ),
                        trailing:
                            IconButton(
                          onPressed:
                              () {
                            deleteNote(
                                index);
                          },
                          icon:
                              const Icon(
                            Icons.delete,
                            color:
                                Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                const Divider(
                  color: Colors.white12,
                ),

                const SizedBox(height: 20),

                const Text(
                  "📅 HARI INI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Belum ada agenda",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                const Divider(
                  color: Colors.white12,
                ),

                const SizedBox(height: 20),

                const Text(
                  "📊 SCREEN TIME",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "0 jam 0 menit",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                const Divider(
                  color: Colors.white12,
                ),

                const SizedBox(height: 20),

                const Text(
                  "🔥 PALING SERING DIBUKA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Belum ada data",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: Text(
                    "↑ Swipe Up untuk membuka aplikasi",
                    style: TextStyle(
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}