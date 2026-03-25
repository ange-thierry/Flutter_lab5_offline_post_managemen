class Post {
  final int? id;
  final String title;
  final String content;
  final String category;
  final String status; // draft, published, archived
  final String authorName;
  final String authorInitials;
  final int authorColorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.status,
    required this.authorName,
    required this.authorInitials,
    required this.authorColorIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'status': status,
      'authorName': authorName,
      'authorInitials': authorInitials,
      'authorColorIndex': authorColorIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      status: map['status'],
      authorName: map['authorName'],
      authorInitials: map['authorInitials'],
      authorColorIndex: map['authorColorIndex'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    String? status,
    String? authorName,
    String? authorInitials,
    int? authorColorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      status: status ?? this.status,
      authorName: authorName ?? this.authorName,
      authorInitials: authorInitials ?? this.authorInitials,
      authorColorIndex: authorColorIndex ?? this.authorColorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
