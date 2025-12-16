import 'package:flutter/material.dart';
import '../../models/job_seeker.dart';
import '../../models/review.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_buttons_style.dart';
import '../../utils/number_formatter.dart';
import '../../utils/time_ago.dart';
import '../../utils/responsive.dart';
import '../../widgets/rating_badge.dart';
import '../chat/chat_screen.dart';
import '../reviews/reviews_screen.dart';

class JobSeekerDetailScreen extends StatelessWidget {
  final JobSeeker seeker;

  const JobSeekerDetailScreen({super.key, required this.seeker});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFE3F2FD),
        appBar: AppBar(
          title: Text('پروفایل کارجو'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: context.responsive.padding(all: 20),
          child: Column(
            children: [
              CircleAvatar(
                radius: context.responsive.spacing(60),
                backgroundColor: AppTheme.primaryGreen,
                backgroundImage: seeker.profileImage != null
                    ? NetworkImage('http://10.0.2.2:3000${seeker.profileImage}')
                    : null,
                child: seeker.profileImage == null
                    ? Text(
                        seeker.firstName[0],
                        style: TextStyle(
                          fontSize: context.responsive.fontSize(48),
                          color: AppTheme.white,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: context.responsive.spacing(16)),
              Text(
                seeker.fullName,
                style: TextStyle(
                  fontSize: context.responsive.fontSize(24),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: context.responsive.spacing(8)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppTheme.primaryGreen),
                    SizedBox(width: 4),
                    Text(
                      TimeAgo.format(seeker.createdAt),
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              RatingBadge(
                targetId: seeker.id,
                targetType: ReviewTargetType.jobSeeker,
                targetName: seeker.fullName,
              ),
              SizedBox(height: 32),
              _buildSimpleCard(
                context,
                'اطلاعات شخصی',
                [
                  _buildSimpleRow(context, Icons.family_restroom, 'وضعیت تاهل',
                      seeker.isMarried ? 'متاهل' : 'مجرد'),
                  _buildSimpleRow(context, Icons.location_on, 'محل سکونت', seeker.location),
                ],
              ),
              SizedBox(height: 16),
              _buildSimpleCard(
                context,
                'مهارت‌های شغلی',
                [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: seeker.skills
                        .map((skill) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildSimpleCard(
                context,
                'اطلاعات مالی',
                [
                  _buildSimpleRow(context, Icons.attach_money, 'حقوق هفتگی درخواستی',
                      NumberFormatter.formatPrice(seeker.expectedSalary)),
                ],
              ),
              SizedBox(height: 16),
              _buildSimpleCard(
                context,
                'سایر اطلاعات',
                [
                  _buildSimpleRow(context, Icons.smoking_rooms, 'سیگار',
                      seeker.isSmoker ? 'بله' : 'خیر'),
                  _buildSimpleRow(context, Icons.warning, 'اعتیاد',
                      seeker.hasAddiction ? 'بله' : 'خیر'),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewsScreen(
                              targetId: seeker.id,
                              targetType: ReviewTargetType.jobSeeker,
                              targetName: seeker.fullName,
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
                              recipientId: seeker.id,
                              recipientName: seeker.fullName,
                              recipientAvatar: seeker.firstName[0],
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

  Widget _buildSimpleCard(BuildContext context, String title, List<Widget> children) {
    final responsive = Responsive(context);
    return Container(
      width: double.infinity,
      padding: responsive.padding(all: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.borderRadius(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSimpleRow(BuildContext context, IconData icon, String label, String value) {
    final responsive = Responsive(context);
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: responsive.iconSize(20),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: responsive.fontSize(14),
                  fontFamily: 'Vazir',
                ),
                children: [
                  TextSpan(text: '$label: '),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
