import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_buttons_style.dart';
import '../../utils/responsive.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final String targetId;
  final ReviewTargetType targetType;
  final String targetName;

  const ReviewsScreen({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late ReviewStats stats;
  late List<Review> reviews;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    stats = ReviewService.getReviewStats(widget.targetId, widget.targetType);
    reviews = ReviewService.getReviewsForTarget(widget.targetId, widget.targetType);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text('نظرات و امتیازها'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: context.responsive.padding(all: 16),
          children: [
            _buildStatsCard(),
            SizedBox(height: context.responsive.spacing(16)),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddReviewScreen(
                        targetId: widget.targetId,
                        targetType: widget.targetType,
                        targetName: widget.targetName,
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    setState(() => _loadData());
                  }
                },
                icon: Icon(Icons.rate_review),
                label: Text('ثبت نظر جدید'),
                style: AppButtonsStyle.elevatedIconButton(),
              ),
            ),
            SizedBox(height: 24),
            
            if (reviews.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_outlined, size: 64, color: AppTheme.textGrey),
                      SizedBox(height: 16),
                      Text(
                        'هنوز نظری ثبت نشده',
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...reviews.map((review) => _buildReviewCard(review)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: context.responsive.padding(all: 20),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  stats.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: context.responsive.fontSize(48),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < stats.averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                SizedBox(height: 4),
                Text(
                  '${stats.totalReviews} نظر',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(width: 32),
            
            Expanded(
              child: Column(
                children: List.generate(5, (index) {
                  final star = 5 - index;
                  final count = stats.ratingDistribution[star] ?? 0;
                  final percentage = stats.totalReviews > 0
                      ? (count / stats.totalReviews)
                      : 0.0;
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('$star', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: AppTheme.background,
                            valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$count',
                          style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: EdgeInsets.only(bottom: context.responsive.spacing(12)),
      child: Padding(
        padding: context.responsive.padding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: context.responsive.spacing(20),
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: Text(
                    review.reviewerAvatar,
                    style: TextStyle(
                      fontSize: context.responsive.fontSize(24),
                    ),
                  ),
                ),
                SizedBox(width: context.responsive.spacing(12)),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                          SizedBox(width: 8),
                          Text(
                            _getTimeAgo(review.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (review.comment.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                review.comment,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark,
                  height: 1.5,
                ),
              ),
            ],
            
            if (review.tags.isNotEmpty) ...[
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: review.tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} ماه پیش';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} روز پیش';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ساعت پیش';
    } else {
      return 'همین الان';
    }
  }
}
