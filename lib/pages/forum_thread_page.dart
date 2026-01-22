import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/forum_message_model.dart';
import 'package:bookbuddies/models/forum_post_model.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/services/forum_message_service.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ForumThreadPage extends StatefulWidget {
  final ForumPost forum;
  final AppUser currentUser;

  const ForumThreadPage({super.key, required this.forum, required this.currentUser});

  @override
  State<ForumThreadPage> createState() => _ForumThreadPageState();
}

class _ForumThreadPageState extends State<ForumThreadPage> {
  final _messageService = ForumMessageService();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final message = ForumMessage(
        id: '',
        text: text,
        senderId: widget.currentUser.id,
        senderName: widget.currentUser.name,
        createdAt: DateTime.now(),
      );
      await _messageService.sendMessage(postId: widget.forum.id, message: message);
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      user: widget.currentUser,
      child: Column(
        children: [
          _buildThreadHeader(),
          const SizedBox(height: 20),
          Container(
            height: 600, // Fixed height for scrollable chat area
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Expanded(child: _buildMessageList()),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadHeader() {
    return Row(
      children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.forum.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Started by ${widget.forum.createdByName}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(widget.forum.id)
          .collection('messages')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final messages = snapshot.data!.docs.map((doc) => ForumMessage.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
        if (messages.isEmpty) return const Center(child: Text('No messages yet. Say hello!'));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderId == widget.currentUser.id;
            return _buildMessageBubble(msg, isMe);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ForumMessage msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(msg.senderName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  ),
                ),
                child: Text(msg.text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
              ),
              if (isMe) IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                onPressed: () => _messageService.deleteMessage(postId: widget.forum.id, messageId: msg.id),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDark
        // subtle green tint for dark mode
        ? AppColors.primary.withOpacity(0.18)
        // light neutral for light mode
        : Colors.grey[100];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Write a message...',
                filled: true,
                fillColor: inputFillColor,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              onPressed: () async => _sendMessage(),
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}