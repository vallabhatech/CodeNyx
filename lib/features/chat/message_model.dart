class MessageModel {
  const MessageModel({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String teamId;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    final parsedCreatedAt =
        DateTime.tryParse((map['created_at'] ?? '').toString())?.toLocal();

    return MessageModel(
      id: map['id'].toString(),
      teamId: (map['team_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      userName: (map['user_name'] ?? 'Unknown').toString(),
      message: (map['message'] ?? '').toString(),
      createdAt: parsedCreatedAt ??
          DateTime.fromMillisecondsSinceEpoch(0).toLocal(),
    );
  }
}