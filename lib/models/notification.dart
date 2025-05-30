// models/notification_model.dart
class NotificationModel {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final String? readAt;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(), // Pastikan id sebagai String
      type: json['type'],
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : {},
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at'].toString(),
    );
  }
}