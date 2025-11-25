import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/job_ad.dart';
import '../../models/review.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_buttons_style.dart';
import '../../utils/number_formatter.dart';
import '../../utils/responsive.dart';
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
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.ad.id, 'job_ad');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('از نشانک‌ها حذف شد'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      await BookmarkService.addBookmark(widget.ad.id, 'job_ad');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('به نشانک‌ها اضافه شد'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('جزئیات آگهی'),
          actions: [
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? Colors.amber : null,
              ),
              onPressed: _toggleBookmark,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.ad.title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 16),
              _buildInfoRow(Icons.category, 'تخصص', widget.ad.category),
              _buildInfoRow(Icons.location_on, 'محل کار', widget.ad.location),
              _buildInfoRow(
                  Icons.shopping_bag, 'تعداد کارکرد روزانه', '${widget.ad.dailyBags} کیسه'),
              _buildInfoRow(
                Icons.attach_money,
                'حقوق هفتگی',
                NumberFormatter.formatPrice(widget.ad.salary),
              ),
              SizedBox(height: 24),
              Text(
                'توضیحات:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Text(widget.ad.description),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.ad.phoneNumber));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('شماره تماس کپی شد'),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.phone),
                  label: Text('تماس: ${widget.ad.phoneNumber}'),
                  style: AppButtonsStyle.primaryButton(),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
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
                      icon: Icon(Icons.rate_review),
                      label: Text('نظرات'),
                      style: AppButtonsStyle.outlinedIconButton(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              userId: '1',
                              userName: 'کارفرما',
                              userAvatar: 'ک',
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.chat_bubble_outline),
                      label: Text('پیام'),
                      style: AppButtonsStyle.outlinedIconButton(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
