class NotificationModel {
  final int id;
  final int userId;
  final String? type;
  final String title;
  final String message;
  final String? link;
  final bool isRead;
  final String? createdAt;
  final String? senderName;
  final int? relatedProjectId;
  final int? relatedItpId;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.type,
    required this.title,
    required this.message,
    this.link,
    required this.isRead,
    this.createdAt,
    this.senderName,
    this.relatedProjectId,
    this.relatedItpId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        type: json['type'] as String?,
        title: json['title'] as String? ?? 'Notifikasi',
        message: json['message'] as String? ?? '',
        link: json['link'] as String?,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] as String?,
        senderName: json['sender'] != null
            ? (json['sender'] as Map<String, dynamic>)['name'] as String?
            : null,
        relatedProjectId: json['related_project_id'] as int?,
        relatedItpId: json['related_itp_id'] as int?,
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        userId: userId,
        type: type,
        title: title,
        message: message,
        link: link,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        senderName: senderName,
        relatedProjectId: relatedProjectId,
        relatedItpId: relatedItpId,
      );
}
