import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../theme/app_theme.dart';
import '../screens/reviews/reviews_screen.dart';

class RatingBadge extends StatelessWidget {
  final String targetId;
  final ReviewTargetType targetType;
  final String targetName;
  final bool showReviewCount;
  final bool isClickable;

  const RatingBadge({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
    this.showReviewCount = true,
    this.isClickable = true,
  });

  @override
  Widget build(BuildContext context) {
    final stats = ReviewService.getReviewStats(targetId, targetType);

    if (stats.totalReviews == 0) {
      return _buildNoRating(context);
    }

    return InkWell(
      onTap: isClickable
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewsScreen(
                    targetId: targetId,
                    targetType: targetType,
                    targetName: targetName,
                  ),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 18),
            SizedBox(width: 4),
            Text(
              stats.averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                fontSize: 14,
              ),
            ),
            if (showReviewCount) ...[
              SizedBox(width: 4),
              Text(
                '(${stats.totalReviews})',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoRating(BuildContext context) {
    return InkWell(
      onTap: isClickable
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewsScreen(
                    targetId: targetId,
                    targetType: targetType,
                    targetName: targetName,
                  ),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, color: AppTheme.textGrey, size: 18),
            SizedBox(width: 4),
            Text(
              'بدون نظر',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
