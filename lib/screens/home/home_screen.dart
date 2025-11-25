import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../job_ads/job_ads_list_screen.dart';
import '../job_seekers/job_seekers_list_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    JobAdsListScreen(),
    JobSeekersListScreen(),
    MarketplaceScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.textGrey,
          selectedFontSize: 10,
          unselectedFontSize: 9,
          iconSize: 24,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: 'نیازمند همکار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search),
              label: 'جویندگان کار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'بازار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'چت',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'پروفایل',
            ),
          ],
        ),
      ),
    );
  }
}
