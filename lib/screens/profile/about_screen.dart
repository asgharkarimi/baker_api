import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('درباره ما'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              
              // لوگو یا آیکون
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bakery_dining,
                  size: 80,
                  color: Color(0xFF2196F3),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'اپلیکیشن نانوایان',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'نسخه 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // کارت اطلاعات طراح
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: AppTheme.primaryGreen,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'طراح و برنامه‌نویس',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // نام
                      Row(
                        children: [
                          Icon(
                            Icons.badge,
                            color: AppTheme.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'اصغر کریمی',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // شماره تماس
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            const ClipboardData(text: '09199541276'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('شماره تماس کپی شد'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '09199541276',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreen,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.copy,
                                color: AppTheme.primaryGreen,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // توضیحات
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'درباره اپلیکیشن',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'این اپلیکیشن برای تسهیل ارتباط بین نانوایان، کارجویان و خریداران تجهیزات نانوایی طراحی شده است.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                '© 2024 تمامی حقوق محفوظ است',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
