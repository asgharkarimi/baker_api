import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/job_ads/add_job_ad_screen.dart';
import '../screens/job_seekers/add_job_seeker_profile_screen.dart';
import '../screens/marketplace/add_equipment_ad_screen.dart';
import '../screens/marketplace/add_bakery_ad_screen.dart';

class AddMenuFab extends StatelessWidget {
  const AddMenuFab({super.key});

  Future<bool> _checkAuth(BuildContext context) async {
    final isLoggedIn = await ApiService.checkAuth();
    
    if (!isLoggedIn && context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.login, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ورود به حساب کاربری',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: const Text('برای ثبت آگهی باید وارد حساب کاربری خود شوید.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('انصراف', style: TextStyle(color: AppTheme.textGrey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('ورود / ثبت‌نام', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
      
      if (result == true && context.mounted) {
        final loginResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        // اگه لاگین موفق بود، true برگردون
        if (loginResult == true) {
          return true;
        }
        return await ApiService.checkAuth();
      }
      return false;
    }
    
    return true;
  }

  void _showAddMenu(BuildContext context) async {
    final isAuthenticated = await _checkAuth(context);
    if (!isAuthenticated || !context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'افزودن آگهی جدید',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildMenuItem(
                  context,
                  icon: Icons.work,
                  title: 'درخواست همکار',
                  subtitle: 'نیاز به کارگر دارید؟',
                  color: Colors.blue,
                  delay: 0,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddJobAdScreen()),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.person_search,
                  title: 'درخواست کار',
                  subtitle: 'به دنبال کار هستید؟',
                  color: Colors.green,
                  delay: 100,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddJobSeekerProfileScreen()),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.store,
                  title: 'رهن و فروش نانوایی',
                  subtitle: 'نانوایی برای فروش یا اجاره',
                  color: Colors.orange,
                  delay: 200,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddBakeryAdScreen()),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'فروش دستگاه',
                  subtitle: 'تجهیزات نانوایی برای فروش',
                  color: Colors.purple,
                  delay: 300,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddEquipmentAdScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
    bool isPaid = false,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(50 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddMenu(context),
      backgroundColor: AppTheme.primaryGreen,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'افزودن آگهی',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
