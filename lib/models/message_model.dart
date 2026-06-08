class MessageModel {
  final int id;
  final String message;
  final String userName;
  final String userRole;
  final int userId;
  final String createdAt;
  final String createdAtFull;

  const MessageModel({
    required this.id,
    required this.message,
    required this.userName,
    required this.userRole,
    required this.userId,
    required this.createdAt,
    required this.createdAtFull,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as int,
        message: json['message'] as String,
        userName: json['user_name'] as String? ?? '-',
        userRole: json['user_role'] as String? ?? '-',
        userId: json['user_id'] as int,
        createdAt: json['created_at'] as String? ?? '',
        createdAtFull: json['created_at_full'] as String? ?? '',
      );
}

class LatestMessageModel {
  final String message;
  final String sender;
  final String time;

  const LatestMessageModel({
    required this.message,
    required this.sender,
    required this.time,
  });

  factory LatestMessageModel.fromJson(Map<String, dynamic> json) => LatestMessageModel(
        message: json['message'] as String,
        sender: json['sender'] as String? ?? '-',
        time: json['time'] as String? ?? '',
      );
}

class MessageChannelModel {
  final int projectId;
  final String namaProject;
  final String kodeProject;
  final int messageCount;
  final int unreadCount;
  final LatestMessageModel? latestMessage;

  const MessageChannelModel({
    required this.projectId,
    required this.namaProject,
    required this.kodeProject,
    required this.messageCount,
    required this.unreadCount,
    this.latestMessage,
  });

  factory MessageChannelModel.fromJson(Map<String, dynamic> json) => MessageChannelModel(
        projectId: json['project_id'] as int,
        namaProject: json['nama_project'] as String,
        kodeProject: json['kode_project'] as String,
        messageCount: json['message_count'] as int? ?? 0,
        unreadCount: json['unread_count'] as int? ?? 0,
        latestMessage: json['latest_message'] != null
            ? LatestMessageModel.fromJson(json['latest_message'] as Map<String, dynamic>)
            : null,
      );
}

class MemberModel {
  final int id;
  final String name;
  final String role;

  const MemberModel({required this.id, required this.name, required this.role});

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id: json['id'] as int,
        name: json['name'] as String,
        role: json['role'] as String,
      );
}
