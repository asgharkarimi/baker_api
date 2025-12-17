import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String recipientAvatar;

  const ChatScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.recipientAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isBlocked = false;
  bool _isOnline = false;
  String? _lastSeen;
  Timer? _refreshTimer;
  Timer? _typingTimer;
  int? _myUserId;
  Map<String, dynamic>? _replyTo;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ApiService.setOnline();
    } else if (state == AppLifecycleState.paused) {
      ApiService.setOffline();
    }
  }

  Future<void> _init() async {
    _myUserId = await ApiService.getCurrentUserId();
    ApiService.setOnline();
    await _loadUserInfo();
    await _loadMessages();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadMessages(showLoading: false);
      _checkTyping();
    });
  }

  Future<void> _loadUserInfo() async {
    final user = await ApiService.getChatUser(int.parse(widget.recipientId));
    if (user != null && mounted) {
      setState(() {
        _isOnline = user['isOnline'] == true;
        _lastSeen = user['lastSeen'];
        _isBlocked = user['isBlocked'] == true;
      });
    }
  }

  Future<void> _checkTyping() async {
    final typing = await ApiService.isTyping(int.parse(widget.recipientId));
    if (mounted && typing != _isTyping) {
      setState(() => _isTyping = typing);
    }
  }

  Future<void> _loadMessages({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    try {
      final messages = await ApiService.getMessages(int.parse(widget.recipientId));
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        if (showLoading) _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onTextChanged(String text) {
    _typingTimer?.cancel();
    ApiService.sendTyping(int.parse(widget.recipientId));
    _typingTimer = Timer(const Duration(seconds: 2), () {});
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final message = _messageController.text.trim();
    _messageController.clear();

    debugPrint('📨 Sending message to recipientId: ${widget.recipientId}');
    debugPrint('📨 My userId: $_myUserId');

    // چک کردن معتبر بودن recipientId
    final recipientIdInt = int.tryParse(widget.recipientId);
    if (recipientIdInt == null || recipientIdInt <= 0) {
      debugPrint('❌ Invalid recipientId: ${widget.recipientId}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا: شناسه گیرنده نامعتبر است'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'senderId': _myUserId,
        'message': message,
        'messageType': 'text',
        'createdAt': DateTime.now().toIso8601String(),
        'replyTo': _replyTo,
      });
      _replyTo = null;
    });
    _scrollToBottom();

    final success = await ApiService.sendMessage(
      recipientIdInt,
      message,
      replyToId: _replyTo?['id'],
    );
    debugPrint('📨 Send result: $success');
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در ارسال پیام'), backgroundColor: Colors.red),
      );
    }
  }


  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _sendMedia(File(image.path), 'image');
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) await _sendMedia(File(video.path), 'video');
  }

  Future<void> _sendMedia(File file, String type) async {
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'senderId': _myUserId,
        'messageType': type,
        'mediaUrl': file.path,
        'createdAt': DateTime.now().toIso8601String(),
        'isLocal': true,
      });
    });
    _scrollToBottom();

    final result = await ApiService.sendChatMedia(
      int.parse(widget.recipientId),
      file,
      type,
      replyToId: _replyTo?['id'],
    );
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در ارسال فایل'), backgroundColor: Colors.red),
      );
    }
    setState(() => _replyTo = null);
  }

  Future<void> _blockUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بلاک کردن'),
        content: Text('آیا می‌خواهید ${widget.recipientName} را بلاک کنید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('خیر')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('بله')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ApiService.blockUser(int.parse(widget.recipientId));
      if (success && mounted) {
        setState(() => _isBlocked = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('کاربر بلاک شد')),
        );
      }
    }
  }

  Future<void> _unblockUser() async {
    final success = await ApiService.unblockUser(int.parse(widget.recipientId));
    if (success && mounted) {
      setState(() => _isBlocked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کاربر آنبلاک شد')),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final time = DateTime.parse(dateStr);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  String _formatLastSeen(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final time = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(time);
      if (diff.inMinutes < 1) return 'همین الان';
      if (diff.inMinutes < 60) return '${diff.inMinutes} دقیقه پیش';
      if (diff.inHours < 24) return '${diff.inHours} ساعت پیش';
      return '${diff.inDays} روز پیش';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    ApiService.setOffline();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1976D2),
                    child: Text(widget.recipientAvatar, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  if (_isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipientName, style: const TextStyle(fontSize: 16)),
                  Text(
                    _isTyping ? 'در حال نوشتن...' : (_isOnline ? 'آنلاین' : _formatLastSeen(_lastSeen)),
                    style: TextStyle(fontSize: 12, color: _isTyping ? Colors.green : Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'block') _blockUser();
                if (value == 'unblock') _unblockUser();
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: _isBlocked ? 'unblock' : 'block',
                  child: Row(
                    children: [
                      Icon(_isBlocked ? Icons.check_circle : Icons.block, color: _isBlocked ? Colors.green : Colors.red),
                      const SizedBox(width: 8),
                      Text(_isBlocked ? 'آنبلاک کردن' : 'بلاک کردن'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isBlocked)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('این کاربر بلاک شده است', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            Expanded(child: _buildMessageList()),
            if (_replyTo != null) _buildReplyPreview(),
            if (!_isBlocked) _buildInputArea(),
          ],
        ),
      ),
    );
  }


  Widget _buildMessageList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            Text('هنوز پیامی ارسال نشده', style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildMessageItem(_messages[index]),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final senderId = message['senderId']?.toString() ?? '';
    final isMe = senderId == _myUserId?.toString();
    final messageType = message['messageType'] ?? 'text';
    final replyTo = message['replyTo'] as Map<String, dynamic>?;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(message),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.primaryGreen : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (replyTo != null) _buildReplyBubble(replyTo, isMe),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMessageContent(message, messageType, isMe),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message['createdAt']),
                      style: TextStyle(color: isMe ? Colors.white70 : AppTheme.textGrey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyBubble(Map<String, dynamic> reply, bool isMe) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border(right: BorderSide(color: isMe ? Colors.white : AppTheme.primaryGreen, width: 3)),
      ),
      child: Text(
        reply['message'] ?? '[${reply['messageType']}]',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : AppTheme.textGrey),
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> message, String type, bool isMe) {
    final mediaUrl = message['mediaUrl'] ?? '';
    final isLocal = message['isLocal'] == true;
    final fullUrl = isLocal ? mediaUrl : 'http://10.0.2.2:3000$mediaUrl';

    switch (type) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isLocal
              ? Image.file(File(mediaUrl), width: 200, fit: BoxFit.cover)
              : Image.network(fullUrl, width: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
        );
      case 'video':
        return _buildVideoPlayer(isLocal ? mediaUrl : fullUrl, isLocal);
      case 'voice':
        return _buildVoicePlayer(isLocal ? mediaUrl : fullUrl, isMe);
      default:
        return Text(message['message'] ?? '', style: TextStyle(color: isMe ? Colors.white : AppTheme.textDark, fontSize: 15));
    }
  }

  Widget _buildVideoPlayer(String url, bool isLocal) {
    return GestureDetector(
      onTap: () => _playVideo(url, isLocal),
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
      ),
    );
  }

  void _playVideo(String url, bool isLocal) {
    debugPrint('🎥 Playing video: $url, isLocal: $isLocal');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(url: url, isLocal: isLocal)),
    );
  }

  Widget _buildVoicePlayer(String url, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow, color: isMe ? Colors.white : AppTheme.primaryGreen),
          onPressed: () => _audioPlayer.play(UrlSource(url)),
        ),
        Container(width: 100, height: 30, decoration: BoxDecoration(color: isMe ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(15))),
      ],
    );
  }


  void _showMessageOptions(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('پاسخ دادن'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _replyTo = message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('کپی متن'),
              onTap: () {
                Navigator.pop(ctx);
                // Clipboard.setData(ClipboardData(text: message['message'] ?? ''));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Container(width: 4, height: 40, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('پاسخ به:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(_replyTo?['message'] ?? '[${_replyTo?['messageType']}]', maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _replyTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _showAttachmentOptions,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText: 'پیام خود را بنویسید...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppTheme.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('تصویر'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: const Text('ویدیو'),
              onTap: () {
                Navigator.pop(ctx);
                _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// صفحه پخش ویدیو
class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final bool isLocal;
  const VideoPlayerScreen({super.key, required this.url, required this.isLocal});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      debugPrint('🎥 Loading video: ${widget.url}');
      if (widget.isLocal) {
        _controller = VideoPlayerController.file(File(widget.url));
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      }
      await _controller!.initialize();
      setState(() {});
      _controller!.play();
    } catch (e) {
      debugPrint('❌ Video error: $e');
      setState(() {
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('پخش ویدیو', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _isError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text('خطا در پخش ویدیو', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text('URL: ${widget.url}', style: const TextStyle(color: Colors.blue, fontSize: 10), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                  ),
                ],
              )
            : _controller != null && _controller!.value.isInitialized
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                        if (!_controller!.value.isPlaying)
                          const Icon(Icons.play_circle_fill, color: Colors.white70, size: 80),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
