import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<_Conversation> conversations = [
    _Conversation(
      id: '1',
      name: 'Sarah Ahmed',
      avatar: '👩',
      lastMessage: 'The house is perfect! When can I move in?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      online: true,
    ),
    _Conversation(
      id: '2',
      name: 'Karim Hassan',
      avatar: '👨',
      lastMessage: 'Your order has been prepared',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      online: true,
    ),
    _Conversation(
      id: '3',
      name: 'Fatima Khan',
      avatar: '👩',
      lastMessage: 'Thanks for the review!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      online: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {})
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return _ConversationTile(conversation: conv);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _Conversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(conversation.avatar, style: const TextStyle(fontSize: 24)),
          ),
          if (conversation.online)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            _formatTime(conversation.timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: conversation.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(conversation: conversation),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

class ChatDetailScreen extends StatefulWidget {
  final _Conversation conversation;

  const ChatDetailScreen({required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<_Message> messages = [
    _Message(
      id: '1',
      text: 'Hi, is the house still available?',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      read: true,
    ),
    _Message(
      id: '2',
      text: 'Yes, it is still available! Would you like to know more details?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      read: true,
    ),
    _Message(
      id: '3',
      text: 'Sure! What\'s the rent and how many bedrooms?',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      read: true,
    ),
    _Message(
      id: '4',
      text: 'It\'s 15,000 BDT per month with 2 bedrooms, 1 bathroom.',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      read: true,
    ),
    _Message(
      id: '5',
      text: 'The house is perfect! When can I move in?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      read: false,
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(
        _Message(
          id: DateTime.now().toString(),
          text: _messageController.text,
          isMe: true,
          timestamp: DateTime.now(),
          read: true,
        ),
      );
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(widget.conversation.avatar, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.conversation.name),
                  Text(
                    widget.conversation.online ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.conversation.online ? AppColors.success : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppColors.primary,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (message.isMe) const SizedBox(width: 50),
            if (!message.isMe) const SizedBox(width: 50),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: message.isMe ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.read ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.read ? Colors.white : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Conversation {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool online;

  _Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.online,
  });
}

class _Message {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final bool read;

  _Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.read,
  });
}
