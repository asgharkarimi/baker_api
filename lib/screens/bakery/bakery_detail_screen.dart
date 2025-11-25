import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/bakery_ad.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_buttons_style.dart';
import '../../utils/number_formatter.dart';
import '../../utils/responsive.dart';
import '../../services/bookmark_service.dart';
import '../chat/chat_screen.dart';
import '../map/map_screen.dart';

class BakeryDetailScreen extends StatefulWidget {
  final BakeryAd ad;

  const BakeryDetailScreen({super.key, required this.ad});

  @override
  State<BakeryDetailScreen> createState() => _BakeryDetailScreenState();
}

class _BakeryDetailScreenState extends State<BakeryDetailScreen> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final isBookmarked = await BookmarkService.isBookmarked(widget.ad.id, 'bakery');
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.ad.id, 'bakery');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('از نشانک‌ها حذف شد'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      await BookmarkService.addBookmark(widget.ad.id, 'bakery');
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
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text('جزئیات آگهی'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
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
          child: Column(
            children: [
              // Main content card
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.ad.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    
                    // Description
                    Text(
                      widget.ad.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textGrey,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    
                    // Location
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'محل',
                      value: widget.ad.location,
                      iconColor: AppTheme.primaryGreen,
                    ),
                    SizedBox(height: 20),
                    
                    // Price info based on type
                    if (widget.ad.type == BakeryAdType.sale) ...[
                      _buildInfoRow(
                        icon: Icons.attach_money,
                        label: 'قیمت فروش',
                        value: NumberFormatter.formatPrice(widget.ad.salePrice!),
                        iconColor: AppTheme.primaryGreen,
                      ),
                    ] else ...[
                      _buildInfoRow(
                        icon: Icons.attach_money,
                        label: 'رهن',
                        value: NumberFormatter.formatPrice(widget.ad.rentDeposit!),
                        iconColor: AppTheme.primaryGreen,
                      ),
                      SizedBox(height: 20),
                      _buildInfoRow(
                        icon: Icons.attach_money,
                        label: 'اجاره ماهانه',
                        value: NumberFormatter.formatPrice(widget.ad.monthlyRent!),
                        iconColor: AppTheme.primaryGreen,
                      ),
                    ],
                    SizedBox(height: 20),
                    
                    // Phone number
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'تماس',
                      value: widget.ad.phoneNumber,
                      iconColor: AppTheme.primaryGreen,
                    ),
                  ],
                ),
              ),
              
              // Buttons
              Padding(
                padding: context.responsive.padding(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MapScreen()),
                          );
                        },
                        icon: Icon(Icons.map),
                        label: Text('نمایش روی نقشه'),
                        style: AppButtonsStyle.primaryButton(verticalPadding: 18),
                      ),
                    ),
                    SizedBox(height: 12),
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
                        style: AppButtonsStyle.primaryButton(verticalPadding: 18),
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
                                  builder: (_) => ChatScreen(
                                    userId: '1',
                                    userName: 'فروشنده',
                                    userAvatar: 'ف',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
