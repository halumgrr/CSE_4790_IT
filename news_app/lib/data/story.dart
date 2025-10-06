class Story {
  final int id;
  final String title;
  final int time;
  final String url;
  final String? text;
  final List<int> kids;

  Story({
    required this.id,
    required this.title,
    required this.time,
    required this.url,
    this.text,
    required this.kids,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      time: json['time'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      text: json['text'] as String?,
      kids: (json['kids'] as List<dynamic>? ?? []).cast<int>(),
    );
  }
}
