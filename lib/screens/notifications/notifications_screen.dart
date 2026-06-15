import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  void _onTapNotification(MessageProvider provider, NotificationModel n) {
    provider.markNotificationRead(n.id);
    // Utamakan deep-link langsung ke detail ITP terkait; jika tak ada, ke modul proyek.
    if (n.relatedItpId != null) {
      context.go('/home/itp/${n.relatedItpId}');
    } else if (n.relatedProjectId != null) {
      context.go('/home/projects/${n.relatedProjectId}/moduls');
    }
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
            color: const Color(0xFFDC2626),
            onRefresh: provider.loadNotifications,
            child: ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, i) => _NotifTile(
                notification: provider.notifications[i],
                onTap: () => _onTapNotification(provider, provider.notifications[i]),
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

  ({IconData icon, Color color}) get _visual {
    switch (notification.type) {
      case 'submit':
        return (icon: Icons.upload_file_outlined, color: const Color(0xFF3B82F6));
      case 'approved':
        return (icon: Icons.check_circle_outline, color: const Color(0xFF10B981));
      case 'needs_revision':
      case 'rejected':
        return (icon: Icons.cancel_outlined, color: const Color(0xFFDC2626));
      default:
        return (icon: Icons.notifications_outlined, color: const Color(0xFF0F172A));
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return Container(
      color: notification.isRead ? null : v.color.withAlpha(13),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead ? Colors.grey.shade200 : v.color.withAlpha(30),
          child: Icon(
            v.icon,
            color: notification.isRead ? Colors.grey : v.color,
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
            ? ((notification.relatedItpId != null || notification.relatedProjectId != null)
                ? const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20)
                : null)
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: v.color,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: onTap,
      ),
    );
  }
}
