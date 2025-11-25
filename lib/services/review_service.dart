import '../models/review.dart';

class ReviewService {
  // دیتای نمونه
  static final List<Review> _reviews = [
    Review(
      id: '1',
      reviewerId: 'user1',
      reviewerName: 'احمد رضایی',
      reviewerAvatar: '👨‍💼',
      targetId: 'jobseeker1',
      targetType: ReviewTargetType.jobSeeker,
      rating: 5,
      comment: 'کارگر بسیار حرفه‌ای و دقیق. کیفیت کار عالی بود.',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      tags: ['حرفه‌ای', 'دقیق', 'باتجربه'],
    ),
    Review(
      id: '2',
      reviewerId: 'user2',
      reviewerName: 'مریم احمدی',
      reviewerAvatar: '👩‍💼',
      targetId: 'jobseeker1',
      targetType: ReviewTargetType.jobSeeker,
      rating: 4,
      comment: 'کار خوبی انجام داد ولی کمی دیر تحویل داد.',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      tags: ['باتجربه'],
    ),
    Review(
      id: '3',
      reviewerId: 'jobseeker1',
      reviewerName: 'علی محمدی',
      reviewerAvatar: '👨',
      targetId: 'employer1',
      targetType: ReviewTargetType.employer,
      rating: 5,
      comment: 'کارفرمای عالی، پرداخت به موقع و رفتار محترمانه.',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      tags: ['قابل اعتماد', 'پرداخت به موقع'],
    ),
  ];

  // دریافت نظرات یک شخص
  static List<Review> getReviewsForTarget(String targetId, ReviewTargetType type) {
    return _reviews
        .where((r) => r.targetId == targetId && r.targetType == type)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // دریافت آمار نظرات
  static ReviewStats getReviewStats(String targetId, ReviewTargetType type) {
    final reviews = getReviewsForTarget(targetId, type);
    
    if (reviews.isEmpty) {
      return ReviewStats.empty();
    }

    final totalReviews = reviews.length;
    final averageRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews;
    
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      distribution[review.rating.round()] = (distribution[review.rating.round()] ?? 0) + 1;
    }

    return ReviewStats(
      averageRating: averageRating,
      totalReviews: totalReviews,
      ratingDistribution: distribution,
    );
  }

  // ثبت نظر جدید
  static Future<void> addReview(Review review) async {
    await Future.delayed(Duration(seconds: 1)); // شبیه‌سازی API
    _reviews.add(review);
  }

  // تگ‌های پیشنهادی
  static List<String> getSuggestedTags(ReviewTargetType type) {
    if (type == ReviewTargetType.jobSeeker) {
      return [
        'حرفه‌ای',
        'باتجربه',
        'دقیق',
        'سریع',
        'قابل اعتماد',
        'مسئولیت‌پذیر',
        'خلاق',
        'صبور',
      ];
    } else {
      return [
        'قابل اعتماد',
        'پرداخت به موقع',
        'رفتار محترمانه',
        'شرایط خوب',
        'محیط کار مناسب',
        'حقوق مناسب',
      ];
    }
  }
}
