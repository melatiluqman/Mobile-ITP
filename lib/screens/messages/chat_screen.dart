import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../models/message_model.dart';
import '../../widgets/common/error_view.dart';

class ChatScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  const ChatScreen({required this.projectId, required this.projectName, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MessageProvider>().loadMessages(widget.projectId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _messageController.clear();
    await context.read<MessageProvider>().sendMessage(widget.projectId, text);
    setState(() => _sending = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.messages.isEmpty) {
            return ErrorView(
              message: provider.error!,
              onRetry: () => provider.loadMessages(widget.projectId),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, i) {
                    final msg = provider.messages[i];
                    final isMe = msg.userId == myId;
                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                ),
              ),
              _InputBar(
                controller: _messageController,
                sending: _sending,
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF0F172A).withAlpha(40),
              child: Text(
                message.userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 4),
                    child: Text(
                      '${message.userName} (${message.userRole.toUpperCase()})',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 2)],
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(message.createdAt, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Tambah inset bawah (system nav/gesture bar) agar input tidak ketutupan.
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4, offset: const Offset(0, -1))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF0F172A),
            child: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: onSend,
                  ),
          ),
        ],
      ),
    );
  }
}
