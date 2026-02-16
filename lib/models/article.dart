class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final String author;
  final DateTime publishedAt;
  final List<String> tags;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.imageUrl,
    required this.author,
    required this.publishedAt,
    this.tags = const [],
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    String? getStringOrNull(dynamic value) {
      if (value == null || value == '') return null;
      return value as String;
    }

    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      imageUrl: getStringOrNull(json['imageUrl']),
      author: json['author'] as String,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(json['publishedAt'] as int),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': (imageUrl == null || imageUrl!.isEmpty) ? null : imageUrl,
      'author': author,
      'publishedAt': publishedAt.millisecondsSinceEpoch,
      'tags': tags,
    };
  }
}
