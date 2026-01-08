import 'package:flutter/material.dart';

/// ویجت پایه Shimmer با انیمیشن روان
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFFE8E8E8),
                Color(0xFFF8F8F8),
                Color(0xFFE8E8E8),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + 2 * _controller.value, 0),
              end: Alignment(1.0 + 2 * _controller.value, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// باکس ساده برای Skeleton
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// دایره برای آواتار
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
    );
  }
}


/// Skeleton برای کارت آگهی شغلی
class JobAdShimmer extends StatelessWidget {
  const JobAdShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(width: 100, height: 36, radius: 25),
                const SizedBox(width: 10),
                const SkeletonBox(width: 90, height: 32, radius: 20),
                const Spacer(),
                const SkeletonCircle(size: 36),
              ],
            ),
            const SizedBox(height: 16),
            const SkeletonBox(width: 180, height: 20),
            const SizedBox(height: 14),
            Row(
              children: const [
                SkeletonBox(width: 80, height: 16),
                SizedBox(width: 20),
                SkeletonBox(width: 70, height: 16),
              ],
            ),
            const SizedBox(height: 14),
            const SkeletonBox(height: 44, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton برای کارت جوینده کار
class JobSeekerShimmer extends StatelessWidget {
  const JobSeekerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ShimmerLoading(
        child: Row(
          children: [
            const SkeletonCircle(size: 70),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 120, height: 18),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Flexible(child: SkeletonBox(width: 60, height: 24, radius: 12)),
                      SizedBox(width: 8),
                      Flexible(child: SkeletonBox(width: 80, height: 24, radius: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 100, height: 14),
                ],
              ),
            ),
            const SkeletonBox(width: 80, height: 36, radius: 18),
          ],
        ),
      ),
    );
  }
}

/// Skeleton برای کارت نانوایی/تجهیزات
class MarketplaceShimmer extends StatelessWidget {
  const MarketplaceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تصویر
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonBox(width: 70, height: 26, radius: 13),
                      SkeletonBox(width: 90, height: 22, radius: 11),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SkeletonBox(width: 200, height: 18),
                  const SizedBox(height: 10),
                  const SkeletonBox(width: 120, height: 14),
                  const SizedBox(height: 12),
                  const SkeletonBox(width: 140, height: 28, radius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton برای لیست چت
class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ShimmerLoading(
        child: Row(
          children: [
            const SkeletonCircle(size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonBox(width: 100, height: 16),
                      SkeletonBox(width: 50, height: 12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 180, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton برای نشانک‌ها
class BookmarkShimmer extends StatelessWidget {
  const BookmarkShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ShimmerLoading(
        child: Row(
          children: [
            const SkeletonBox(width: 56, height: 56, radius: 16),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonBox(width: 140, height: 16),
                      SkeletonBox(width: 60, height: 20, radius: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 100, height: 14),
                  const SizedBox(height: 6),
                  const SkeletonBox(width: 80, height: 14),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const SkeletonCircle(size: 36),
          ],
        ),
      ),
    );
  }
}

/// Skeleton برای صفحه جزئیات
class DetailShimmer extends StatelessWidget {
  const DetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تصویر بزرگ
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            const SkeletonBox(width: 250, height: 24),
            const SizedBox(height: 12),
            Row(
              children: const [
                SkeletonBox(width: 80, height: 28, radius: 14),
                SizedBox(width: 12),
                SkeletonBox(width: 100, height: 28, radius: 14),
              ],
            ),
            const SizedBox(height: 20),
            const SkeletonBox(height: 16),
            const SizedBox(height: 8),
            const SkeletonBox(height: 16),
            const SizedBox(height: 8),
            const SkeletonBox(width: 200, height: 16),
            const SizedBox(height: 24),
            const SkeletonBox(height: 100, radius: 16),
            const SizedBox(height: 20),
            const SkeletonBox(height: 50, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// لیست Shimmer با تعداد دلخواه
class ShimmerList extends StatelessWidget {
  final int count;
  final Widget Function() shimmerBuilder;

  const ShimmerList({
    super.key,
    this.count = 5,
    required this.shimmerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => shimmerBuilder(),
    );
  }
}
