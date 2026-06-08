import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/message_provider.dart';
import '../../models/notification_model.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          Consumer<MessageProvider>(
            builder: (context, provider, child) {
              final hasUnread = provider.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: provider.markAllNotificationsRead,
                child: const Text('Tandai Semua', style: TextStyle(color: Colors.white, fontSize: 12)),
              );
            },
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) return const LoadingView();
          if (provider.error != null && provider.notifications.isEmpty) {
            return ErrorView(message: provider.error!, onRetry: provider.loadNotifications);
          }
          if (provider.notifications.isEmpty) {
            return const EmptyView(
              message: 'Tidak ada notifikasi',
              icon: Icons.notifications_off_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: provider.loadNotifications,
            child: ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, i) => _NotifTile(
                notification: provider.notifications[i],
                onTap: () => provider.markNotificationRead(provider.notifications[i].id),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  const _NotifTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead ? null : const Color(0xFF0F172A).withAlpha(13),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey.shade200
              : const Color(0xFF0F172A).withAlpha(40),
          child: Icon(
            Icons.notifications_outlined,
            color: notification.isRead ? Colors.grey : const Color(0xFF0F172A),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message, style: const TextStyle(fontSize: 13)),
            if (notification.senderName != null)
              Text('Dari: ${notification.senderName}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            if (notification.createdAt != null)
              Text(notification.createdAt!,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        isThreeLine: true,
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
              ),
        onTap: notification.isRead ? null : onTap,
      ),
    );
  }
}
