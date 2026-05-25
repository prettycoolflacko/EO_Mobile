import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/features/chat/domain/entities/chat_message.dart';
import 'package:eventsync_mobile/features/chat/presentation/providers/chat_provider.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int eventId;

  const ChatScreen({super.key, required this.eventId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late final ChatParams _params;

  @override
  void initState() {
    super.initState();
    // For now we assume a general division chat or get the division from the current user
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(currentUserProvider);
    _params = ChatParams(
      eventId: widget.eventId,
      divisi: (user?.divisi != null && user!.divisi!.isNotEmpty) ? user.divisi : 'Umum',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatNotifierProvider(_params).notifier).sendMessage(text);
    _messageController.clear();
    
    // Scroll to bottom (assuming list is reversed)
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider(_params));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat Koordinasi'),
            if (_params.divisi != null)
              Text(
                'Divisi: ${_params.divisi}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (currentUser?.divisi == null || currentUser!.divisi!.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.warning.withAlpha(40),
              width: double.infinity,
              child: const Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: AppColors.warning),
                  Gap(12),
                  Expanded(
                    child: Text(
                      'Anda tidak memiliki divisi. Mengirim pesan dinonaktifkan. Silakan perbarui divisi Anda di Profil.',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Messages List
          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chatState.messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.messageCircle,
                                size: 64, color: AppColors.textSecondary),
                            Gap(16),
                            Text('Belum ada pesan',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Newest messages at bottom
                        padding: const EdgeInsets.all(16),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chatState.messages[index];
                          final isMe = msg.senderId == currentUser?.id;
                          // Check if previous message was from same user
                          final isConsecutive = index < chatState.messages.length - 1 &&
                              chatState.messages[index + 1].senderId == msg.senderId;

                          return _ChatBubble(
                            message: msg,
                            isMe: isMe,
                            showAvatar: !isMe && !isConsecutive,
                            showName: !isMe && !isConsecutive,
                          );
                        },
                      ),
          ),

          // Error banner
          if (chatState.errorMessage != null && !chatState.isLoading)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.error.withAlpha(50),
              child: Row(
                children: [
                    const Icon(LucideIcons.alertTriangle,
                      color: AppColors.error, size: 16),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      chatState.errorMessage!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.surfaceContainer)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Attachment picker (Phase 4 stretch goal)
                  },
                  icon: const Icon(LucideIcons.paperclip, color: AppColors.textSecondary),
                ),
                const Gap(8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !(currentUser?.divisi == null || currentUser!.divisi!.isEmpty),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: (currentUser?.divisi == null || currentUser!.divisi!.isEmpty)
                          ? 'Mengirim dinonaktifkan...'
                          : 'Ketik pesan...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      fillColor: AppColors.surfaceVariant,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                CircleAvatar(
                  backgroundColor: (currentUser?.divisi == null || currentUser!.divisi!.isEmpty)
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  radius: 24,
                  child: IconButton(
                    onPressed: (currentUser?.divisi == null || currentUser!.divisi!.isEmpty) || chatState.isSending
                        ? null
                        : _sendMessage,
                    icon: chatState.isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(LucideIcons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final bool showName;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.showName,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: EdgeInsets.only(
        bottom: showAvatar ? 12.0 : 4.0,
        left: isMe ? 40.0 : 0.0,
        right: isMe ? 0.0 : 40.0,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withAlpha(50),
                child: Text(
                  message.senderName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              )
            else
              const SizedBox(width: 28),
            const Gap(8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showName && !isMe) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.cardDark,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe || !showAvatar ? 16 : 4),
                      bottomRight: Radius.circular(!isMe || !showAvatar ? 16 : 4),
                    ),
                    border: isMe ? null : Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.pesan,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        timeFormat.format(message.createdAt),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
