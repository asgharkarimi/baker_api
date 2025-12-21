import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../models/equipment_ad.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../services/bookmark_service.dart';
import '../../services/api_service.dart';
import '../chat/chat_screen.dart';
import '../map/map_screen.dart';
import 'add_equipment_ad_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final EquipmentAd ad;

  const EquipmentDetailScreen({super.key, required this.ad});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  bool _isBookmarked = false;
  bool _isOwner = false;
  bool _isLoggedIn = false;
  int _currentMediaIndex = 0;
  final PageController _pageController = PageController();
  late EquipmentAd _ad;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _ad = widget.ad;
    _checkBookmark();
    _checkOwnership();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await ApiService.isLoggedIn();
    if (mounted) {
      setState(() => _isLoggedIn = loggedIn);
    }
  }

  Future<void> _refreshData() async {
    await _checkBookmark();
  }
  
  Future<void> _checkOwnership() async {
    final userId = await ApiService.getCurrentUserId();
    if (mounted && userId != null) {
      setState(() => _isOwner = _ad.userId == userId);
    }
  }

  Future<void> _checkBookmark() async {
    final isBookmarked = await BookmarkService.isBookmarked(widget.ad.id, 'equipment');
    if (mounted) setState(() => _isBookmarked = isBookmarked);
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.ad.id, 'equipment');
    } else {
      await BookmarkService.addBookmark(widget.ad.id, 'equipment');
    }
    if (mounted) {
      setState(() => _isBookmarked = !_isBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'به نشانک‌ها اضافه شد' : 'از نشانک‌ها حذف شد'),
          backgroundColor: _isBookmarked ? AppTheme.primaryGreen : Colors.red,
        ),
      );
    }
  }

  void _shareAd() {
    final shareText = '''
🔧 آگهی تجهیزات نانوایی

📌 ${_ad.title}
💰 قیمت: ${NumberFormatter.formatPrice(_ad.price)}
📦 وضعیت: ${_ad.condition == 'new' ? 'نو' : 'کارکرده'}
📍 آدرس: ${_ad.location}
📞 تماس: ${_ad.phoneNumber}

${_ad.description.isNotEmpty ? '📝 توضیحات: ${_ad.description}' : ''}

📱 اپلیکیشن کاریابی نانوایی
''';
    Share.share(shareText.trim(), subject: _ad.title);
  }

  List<String> get _allMedia {
    final media = <String>[];
    media.addAll(_ad.images);
    media.addAll(_ad.videos);
    return media;
  }

  bool _isVideo(String url) {
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi') || _ad.videos.contains(url);
  }

  void _initVideoPlayer(String url) {
    _videoController?.dispose();
    final videoUrl = url.startsWith('http') ? url : '${ApiService.serverUrl}$url';
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.primaryGreen,
          child: CustomScrollView(
            slivers: [
              // App Bar with Image/Video Slider
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.teal,
                flexibleSpace: FlexibleSpaceBar(
                  background: _allMedia.isNotEmpty
                      ? _buildMediaSlider()
                      : _buildDefaultHeader(),
                ),
                actions: [
                  if (_isOwner)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEquipmentAdScreen(adToEdit: _ad),
                          ),
                        );
                        if (result == true && mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                  IconButton(
                    icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                    onPressed: _toggleBookmark,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: _shareAd,
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Title Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _ad.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          if (_ad.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              _ad.description,
                              style: TextStyle(fontSize: 15, color: AppTheme.textGrey, height: 1.6),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Price & Condition Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.monetization_on, color: AppTheme.primaryGreen),
                              const SizedBox(width: 8),
                              const Text('اطلاعات قیمت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildPriceRow('قیمت', NumberFormatter.formatPrice(_ad.price), Colors.teal),
                          const SizedBox(height: 12),
                          _buildPriceRow('وضعیت', _ad.condition == 'new' ? 'نو' : 'کارکرده', 
                            _ad.condition == 'new' ? Colors.green : Colors.orange),
                        ],
                      ),
                    ),

                    // Equipment Info Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text('مشخصات دستگاه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoItem(Icons.visibility, 'بازدید', '${_ad.views} بار', Colors.grey),
                          _buildInfoItem(Icons.image, 'تعداد تصاویر', '${_ad.images.length} عکس', Colors.blue),
                          if (_ad.videos.isNotEmpty)
                            _buildInfoItem(Icons.videocam, 'تعداد ویدیو', '${_ad.videos.length} ویدیو', Colors.red),
                        ],
                      ),
                    ),

                    // Location Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('موقعیت مکانی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            _ad.location,
                            style: TextStyle(fontSize: 14, color: AppTheme.textGrey, height: 1.6),
                            textAlign: TextAlign.center,
                          ),
                          if (_ad.lat != null && _ad.lng != null) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MapScreen(lat: _ad.lat, lng: _ad.lng, title: _ad.title),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.map),
                                label: const Text('نمایش روی نقشه'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Contact Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.contact_phone, color: AppTheme.primaryGreen),
                              const SizedBox(width: 8),
                              const Text('اطلاعات تماس', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (!_isLoggedIn) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('برای مشاهده شماره تماس ابتدا وارد شوید')),
                                      );
                                      return;
                                    }
                                    Clipboard.setData(ClipboardData(text: _ad.phoneNumber));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: const Text('شماره کپی شد'), backgroundColor: AppTheme.primaryGreen),
                                    );
                                  },
                                  icon: const Icon(Icons.phone),
                                  label: Text(_isLoggedIn ? _ad.phoneNumber : '***********'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isLoggedIn ? AppTheme.primaryGreen : Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  if (!_isLoggedIn) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('برای ارسال پیام ابتدا وارد شوید')),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        recipientId: _ad.userId.toString(),
                                        recipientName: 'فروشنده',
                                        recipientAvatar: 'ف',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('پیام'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSlider() {
    return Stack(
      children: [
        // Media PageView
        PageView.builder(
          controller: _pageController,
          itemCount: _allMedia.length,
          onPageChanged: (index) {
            setState(() => _currentMediaIndex = index);
            // اگه ویدیو بود، پلیر رو آماده کن
            if (_isVideo(_allMedia[index])) {
              _initVideoPlayer(_allMedia[index]);
            } else {
              _videoController?.pause();
            }
          },
          itemBuilder: (context, index) {
            final mediaUrl = _allMedia[index];
            final fullUrl = mediaUrl.startsWith('http') ? mediaUrl : '${ApiService.serverUrl}$mediaUrl';
            
            if (_isVideo(mediaUrl)) {
              return _buildVideoPlayer(fullUrl);
            } else {
              return GestureDetector(
                onTap: () => _showFullImage(context, fullUrl),
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                ),
              );
            }
          },
        ),
        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
              ),
            ),
          ),
        ),
        // Condition badge
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _ad.condition == 'new' ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _ad.condition == 'new' ? '✨ نو' : '🔧 کارکرده',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Page indicator
        if (_allMedia.length > 1)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isVideo(_allMedia[_currentMediaIndex]) ? Icons.videocam : Icons.image,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentMediaIndex + 1} / ${_allMedia.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        // Dots indicator
        if (_allMedia.length > 1)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _allMedia.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentMediaIndex == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentMediaIndex == index 
                        ? (_isVideo(_allMedia[index]) ? Colors.red : Colors.white)
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer(String url) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
            _isVideoPlaying = false;
          } else {
            _videoController!.play();
            _isVideoPlaying = true;
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          if (!_isVideoPlaying)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal.shade400, Colors.teal.shade700],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.build, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _ad.condition == 'new' ? '✨ نو' : '🔧 کارکرده',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'بدون تصویر',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: color)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, color: AppTheme.textGrey)),
          ),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
