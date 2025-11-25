import 'package:flutter/material.dart';
import '../../models/chat_conversation.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: '1',
      userId: '1',
      userName: 'علی محمدی',
      userAvatar: 'ع',
      lastMessage: ChatMessage(
        id: '1',
        senderId: '1',
        senderName: 'علی محمدی',
        receiverId: 'me',
        message: 'سلام، آگهی شما هنوز فعاله؟',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      unreadCount: 2,
    ),
    ChatConversation(
      id: '2',
      userId: '2',
      userName: 'حسین احمدی',
      userAvatar: 'ح',
      lastMessage: ChatMessage(
        id: '2',
        senderId: 'me',
        senderName: 'من',
        receiverId: '2',
        message: 'بله حتماً، فردا میام',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
      ),
      unreadCount: 0,
    ),
    ChatConversation(
      id: '3',
      userId: '3',
      userName: 'رضا کریمی',
      userAvatar: 'ر',
      lastMessage: ChatMessage(
        id: '3',
        senderId: '3',
        senderName: 'رضا کریمی',
        receiverId: 'me',
        message: 'ممنون از پاسخگویی شما',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      unreadCount: 0,
    ),
  ];

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} دقیقه پیش';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ساعت پیش';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} روز پیش';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFE3F2FD),
        appBar: AppBar(
          title: Text('پیام‌ها'),
        ),
        body: _conversations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: AppTheme.textGrey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'هنوز پیامی ندارید',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              userId: conversation.userId,
                              userName: conversation.userName,
                              userAvatar: conversation.userAvatar,
                            ),
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFF1976D2),
                            child: Text(
                              conversation.userAvatar,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (conversation.unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  '${conversation.unreadCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        conversation.userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      subtitle: conversation.lastMessage != null
                          ? Text(
                              conversation.lastMessage!.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: conversation.unreadCount > 0
                                    ? AppTheme.textDark
                                    : AppTheme.textGrey,
                                fontWeight: conversation.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            )
                          : null,
                      trailing: conversation.lastMessage != null
                          ? Text(
                              _formatTime(conversation.lastMessage!.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
