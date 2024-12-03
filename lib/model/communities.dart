class Communities {
  const Communities({
    required this.documentId, // 문서 ID 추가
    required this.id,
    required this.name,
    required this.photo,
    required this.description,
    required this.likes,
    required this.created_at,
    required this.userId,
  });

  final String documentId; // Firestore 문서 ID
  final int id;
  final String name;
  final String photo;
  final String description;
  final int likes;
  final DateTime created_at;
  final String userId;

  Communities copyWith({
    String? documentId,
    int? id,
    String? name,
    String? photo,
    String? description,
    int? likes,
    DateTime? created_at,
    String? userId,
  }) {
    return Communities(
      documentId: documentId ?? this.documentId, // 문서 ID 복사
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      created_at: created_at ?? this.created_at,
      userId: userId ?? this.userId,
    );
  }
}
