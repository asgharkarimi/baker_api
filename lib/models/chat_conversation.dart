import 'chat_message.dart';

class ChatConversation {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.lastMessage,
    this.unreadCount = 0,
  });
}
