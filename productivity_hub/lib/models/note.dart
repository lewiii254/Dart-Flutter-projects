class Note {
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String title;
  final String content;
  final DateTime timestamp;

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      timestamp: DateTime.tryParse((map['timestamp'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
