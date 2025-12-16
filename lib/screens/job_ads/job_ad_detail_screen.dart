import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/job_ad.dart';
import '../../models/review.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../utils/time_ago.dart';
import '../../services/bookmark_service.dart';
import '../chat/chat_screen.dart';
import '../reviews/reviews_screen.dart';

class JobAdDetailScreen extends StatefulWidget {
  final JobAd ad;

  const JobAdDetailScreen({super.key, required this.ad});

  @override
  State<JobAdDetailScreen> createState() => _JobAdDetailScreenState();
}

class _JobAdDetailScreenState extends State<JobAdDetailScreen> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final isBookmarked = await BookmarkService.isBookmarked(widget.ad.id, 'job_ad');
    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.ad.id, 'job_ad');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('از نشانک‌ها حذف شد'), backgroundColor: Colors.red),
        );
      }
    } else {
      await BookmarkService.addBookmark(widget.ad.id, 'job_ad');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('به نشانک‌ها اضافه شد'), backgroundColor: AppTheme.primaryGreen),
        );
      }
    }
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  void _copyPhoneNumber() {
    Clipboard.setData(ClipboardData(text: widget.ad.phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('شماره تماس کپی شد'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: CustomScrollView(
          slivers: [
            // Header با گرادیانت
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.primaryGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryGreen.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.ad.category,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.ad.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                TimeAgo.format(widget.ad.createdAt),
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _isBookmarked ? Colors.amber : Colors.white,
                      size: 22,
                    ),
                  ),
                  onPressed: _toggleBookmark,
                ),
                const SizedBox(width: 8),
              ],
            ),

            // محتوا
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // کارت اطلاعات اصلی
                        _buildMainInfoCard(),
                        const SizedBox(height: 16),

                        // کارت حقوق
                        _buildSalaryCard(),
                        const SizedBox(height: 16),

                        // توضیحات
                        if (widget.ad.description.isNotEmpty) ...[
                          _buildDescriptionCard(),
                          const SizedBox(height: 16),
                        ],

                        // دکمه‌ها
                        const SizedBox(height: 8),
                        _buildActionButtons(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // دکمه تماس ثابت پایین
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.work_outline,
            iconColor: const Color(0xFF42A5F5),
            label: 'تخصص مورد نیاز',
            value: widget.ad.category,
          ),
          const Divider(height: 24),
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFFEF5350),
            label: 'محل کار',
            value: widget.ad.location,
          ),
          const Divider(height: 24),
          _buildInfoItem(
            icon: Icons.shopping_bag_outlined,
            iconColor: const Color(0xFFFF9800),
            label: 'کارکرد روزانه',
            value: '${widget.ad.dailyBags} کیسه',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حقوق هفتگی',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormatter.formatPrice(widget.ad.salary),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'توضیحات',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.ad.description,
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.rate_review_outlined,
            label: 'نظرات',
            color: const Color(0xFF42A5F5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewsScreen(
                    targetId: widget.ad.id,
                    targetType: ReviewTargetType.employer,
                    targetName: 'کارفرما',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'پیام',
            color: const Color(0xFF9C27B0),
            onTap: () {
              if (widget.ad.userId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('امکان ارسال پیام وجود ندارد')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    recipientId: widget.ad.userId,
                    recipientName: widget.ad.userName.isNotEmpty ? widget.ad.userName : 'کارفرما',
                    recipientAvatar: widget.ad.userName.isNotEmpty ? widget.ad.userName[0] : 'ک',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_outlined,
            label: 'اشتراک',
            color: const Color(0xFFFF9800),
            onTap: () {
              Clipboard.setData(ClipboardData(
                text: '${widget.ad.title}\nحقوق: ${NumberFormatter.formatPrice(widget.ad.salary)}\nتماس: ${widget.ad.phoneNumber}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اطلاعات آگهی کپی شد')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // دکمه کپی شماره
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryGreen),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.ad.phoneNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('شماره تماس کپی شد'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                icon: Icon(Icons.copy, color: AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(width: 12),
            // دکمه تماس
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _copyPhoneNumber,
                icon: const Icon(Icons.phone, color: Colors.white),
                label: Text(
                  'تماس: ${widget.ad.phoneNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
