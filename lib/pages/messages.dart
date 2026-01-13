import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';

enum MessageType { support, system, delivery }

class ChatPreview {
  final String senderName;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final bool isOnline;
  final MessageType type;

  const ChatPreview({
    required this.senderName,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.type,
  });
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Key _refreshKey = UniqueKey();

  Future<void> _markAllAsRead() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.userId == null || auth.token == null) return;

    await OrderService.markAllNotificationsAsRead(auth.userId!, auth.token!);

    setState(() {
      _refreshKey = UniqueKey();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All messages marked as read"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool canFetchData =
        auth.isAuthenticated && auth.userId != null && auth.token != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        actions: [
          if (canFetchData)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                "Mark all as read",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: !canFetchData
          ? _buildEmptyState(theme)
          : FutureBuilder<List<ChatPreview>>(
              key: _refreshKey,
              future: OrderService.fetchOrderNotifications(
                auth.userId!,
                auth.token!,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error loading messages"));
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: chats.length,
                  separatorBuilder: (context, index) => Divider(
                    indent: 80,
                    endIndent: 20,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return _buildChatTile(chat, theme, isDark);
                  },
                );
              },
            ),
    );
  }

  Widget _buildChatTile(ChatPreview chat, ThemeData theme, bool isDark) {
    return ListTile(
      onTap: () {},
      leading: _buildAvatar(chat, theme, isDark),
      title: Text(
        chat.senderName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: chat.type == MessageType.system ? theme.primaryColor : null,
        ),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: chat.unreadCount > 0
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ChatPreview chat, ThemeData theme, bool isDark) {
    if (chat.type == MessageType.system) {
      IconData iconData = Icons.local_shipping_outlined;
      if (chat.lastMessage.contains("Delivered"))
        iconData = Icons.check_circle_outline;
      if (chat.lastMessage.contains("Placed"))
        iconData = Icons.shopping_bag_outlined;

      return CircleAvatar(
        radius: 28,
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        child: Icon(iconData, color: theme.primaryColor),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundImage: NetworkImage(chat.avatarUrl),
      backgroundColor: theme.dividerColor,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            "No notifications yet",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
