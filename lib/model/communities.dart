class Communities {
  const Communities({
    required this.id,
    required this.name,
    required this.photo,
    required this.description,
    required this.likes,
    required this.created_at,
    required this.userId,
  });

  final int id;
  final String name;
  final String photo;
  final String description;
  final int likes;
  final DateTime created_at;
  final String userId;
}
