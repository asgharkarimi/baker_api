class Review {
  final String id;
  final String reviewerId; // کسی که نظر میده
  final String reviewerName;
  final String reviewerAvatar;
  final String targetId; // کسی که نظر میگیره (کارجو یا کارفرما)
  final ReviewTargetType targetType;
  final double rating; // 1 تا 5
  final String comment;
  final DateTime createdAt;
  final List<String> tags; // مثلاً: حرفه‌ای، باتجربه، قابل اعتماد

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.tags = const [],
  });
}

enum ReviewTargetType {
  jobSeeker, // کارجو
  employer, // کارفرما
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // تعداد هر ستاره

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStats.empty() {
    return ReviewStats(
      averageRating: 0,
      totalReviews: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    );
  }
}
