import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';

class PaymentScreen extends StatelessWidget {
  final String adType;
  final int amount;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.adType,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('پرداخت هزینه آگهی'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // کارت اطلاعات پرداخت
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.primaryGreen.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'هزینه ثبت آگهی',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                adType,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'مبلغ قابل پرداخت:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          NumberFormatter.formatPrice(amount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // توضیحات
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'پس از پرداخت موفق، آگهی شما منتشر خواهد شد.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // مزایا
              Text(
                'مزایای ثبت آگهی:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildFeature(Icons.visibility, 'نمایش به هزاران کاربر'),
              _buildFeature(Icons.verified, 'آگهی تایید شده'),
              _buildFeature(Icons.support_agent, 'پشتیبانی 24 ساعته'),
              _buildFeature(Icons.trending_up, 'افزایش فروش'),
              
              const SizedBox(height: 40),
              
              // دکمه پرداخت
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _processPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'پرداخت ${NumberFormatter.formatPrice(amount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // نمایش دیالوگ در حال پردازش
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryGreen),
              const SizedBox(height: 16),
              const Text('در حال اتصال به درگاه پرداخت...'),
            ],
          ),
        ),
      ),
    );

    // شبیه‌سازی پرداخت (در واقعیت باید به درگاه پرداخت متصل شود)
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // بستن دیالوگ loading
      
      // نمایش دیالوگ موفقیت
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Text('پرداخت موفق'),
              ],
            ),
            content: const Text('پرداخت شما با موفقیت انجام شد.\nآگهی شما منتشر خواهد شد.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // بستن دیالوگ
                  Navigator.pop(context); // بستن صفحه پرداخت
                  onPaymentSuccess(); // ادامه فرآیند ثبت آگهی
                },
                child: const Text('تایید'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
