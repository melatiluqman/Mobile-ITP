import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/message_provider.dart';
import '../../models/message_model.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';

class MessageChannelsScreen extends StatefulWidget {
  const MessageChannelsScreen({super.key});

  @override
  State<MessageChannelsScreen> createState() => _MessageChannelsScreenState();
}

class _MessageChannelsScreenState extends State<MessageChannelsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.channels.isEmpty) return const LoadingView();
          if (provider.error != null && provider.channels.isEmpty) {
            return ErrorView(message: provider.error!, onRetry: provider.loadChannels);
          }
          if (provider.channels.isEmpty) {
            return const EmptyView(message: 'Tidak ada channel pesan', icon: Icons.chat_bubble_outline);
          }
          return RefreshIndicator(
            onRefresh: provider.loadChannels,
            child: ListView.builder(
              itemCount: provider.channels.length,
              itemBuilder: (context, i) => _ChannelTile(channel: provider.channels[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final MessageChannelModel channel;
  const _ChannelTile({required this.channel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF0F172A),
        child: Text(
          channel.kodeProject.substring(0, channel.kodeProject.length.clamp(0, 2)).toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(channel.namaProject, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        channel.latestMessage?.message ?? 'Belum ada pesan',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (channel.latestMessage != null)
            Text(channel.latestMessage!.time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          if (channel.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${channel.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
        ],
      ),
      onTap: () => context.go(
        '/home/messages/${channel.projectId}/chat',
        extra: {'name': channel.namaProject},
      ),
    );
  }
}
