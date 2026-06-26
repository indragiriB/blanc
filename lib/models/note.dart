class Note {
  String text;
  bool done;

  Note({
    required this.text,
    required this.done,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'done': done,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      text: json['text'],
      done: json['done'],
    );
  }
}