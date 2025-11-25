import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_buttons_style.dart';
import '../../utils/responsive.dart';

class AddReviewScreen extends StatefulWidget {
  final String targetId;
  final ReviewTargetType targetType;
  final String targetName;

  const AddReviewScreen({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5;
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reviewerId: 'current_user',
      reviewerName: 'شما',
      reviewerAvatar: '👤',
      targetId: widget.targetId,
      targetType: widget.targetType,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
      tags: _selectedTags.toList(),
    );

    await ReviewService.addReview(review);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('نظر شما با موفقیت ثبت شد'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestedTags = ReviewService.getSuggestedTags(widget.targetType);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text('ثبت نظر'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: context.responsive.padding(all: 16),
            children: [
              // نام هدف
              Card(
                child: Padding(
                  padding: context.responsive.padding(all: 16),
                  child: Row(
                    children: [
                      Icon(
                        widget.targetType == ReviewTargetType.jobSeeker
                            ? Icons.person
                            : Icons.business,
                        color: AppTheme.primaryGreen,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نظر شما درباره:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.targetName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // امتیاز
              Text(
                'امتیاز شما',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () {
                              setState(() => _rating = (index + 1).toDouble());
                            },
                            icon: Icon(
                              index < _rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 40,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // تگ‌ها
              Text(
                'ویژگی‌ها (اختیاری)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestedTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),

              // نظر
              Text(
                'نظر شما',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _commentController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'تجربه خود را با دیگران به اشتراک بگذارید...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.comment, color: AppTheme.primaryGreen),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) {
                    return 'لطفاً نظر خود را بنویسید';
                  }
                  if (v!.trim().length < 10) {
                    return 'نظر شما باید حداقل 10 کاراکتر باشد';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // دکمه ثبت
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: AppButtonsStyle.primaryButton(verticalPadding: 18),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('ثبت نظر'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
