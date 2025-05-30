// screens/notifikasi_screen.dart
import 'package:flutter/material.dart';
import 'package:perpus_flutter/models/notification.dart';
import 'package:perpus_flutter/services/notification_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  NotifikasiScreenState createState() => NotifikasiScreenState();
}

class NotifikasiScreenState extends State<NotifikasiScreen> {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _notificationService.fetchNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(child: Text('Tidak ada notifikasi'));
    }

    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: const Color.fromARGB(255, 98, 169, 240),
          child: ListTile(
            title: Row(
              children: [
                const Text(
                  'Judul buku: ',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '${notification.data['bookTitle'] ?? 'No Title'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.data['message'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  notification.createdAt,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
