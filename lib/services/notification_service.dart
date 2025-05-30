// services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpus_flutter/config/config.dart';
import 'package:perpus_flutter/models/notification.dart';

class NotificationService {
  Future<List<NotificationModel>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak tersedia');
    }

    final uri = Uri.parse(Config.baseUrl('notifications'));

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final notificationList = data['data'];
        if (notificationList is List) {
          return notificationList
              .map<NotificationModel>((item) => NotificationModel.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal memuat notifikasi');
      }
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }
}
