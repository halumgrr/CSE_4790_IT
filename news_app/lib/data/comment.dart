class Comment {
  final int id;
  final String by;
  final int time;
  final String? text;
  final List<int> kids;

  Comment({
    required this.id,
    required this.by,
    required this.time,
    this.text,
    required this.kids,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      by: json['by'] as String? ?? 'Unknown',
      time: json['time'] as int? ?? 0,
      text: json['text'] as String?,
      kids: (json['kids'] as List<dynamic>? ?? []).cast<int>(),
    );
  }
}
