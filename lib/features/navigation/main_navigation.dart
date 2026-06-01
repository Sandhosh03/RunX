import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../history/history_screen.dart';
import '../statistics/analytics_screen.dart';
import '../coach/coach_screen.dart';
import '../profile/profile_screen.dart';
import '../community/community_screen.dart';
import '../../core/theme/app_colors.dart';
import '../settings/personal_info_screen.dart';
import '../../services/profile_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final profile = await ProfileService.getProfile();
    if (profile == null || !profile.isComplete) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
        (route) => false,
      );
    }
  }

  final List<Widget> screens = const [
    HomeScreen(),

    HistoryScreen(),

    CoachScreen(),

    AnalyticsScreen(),

    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0, right: 10),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommunityScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 2)),
          child: const Icon(Icons.people_alt_rounded, color: Colors.black, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 25,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),

        decoration: BoxDecoration(
          color: AppColors.surface,

          borderRadius: BorderRadius.circular(
            20,
          ),

          border: Border.all(
            color: AppColors.outline,
            width: 1,
          ),
        ),

        child: BottomNavigationBar(
          currentIndex: currentIndex,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.transparent,

          elevation: 0,

          selectedItemColor:
              AppColors.primary,

          unselectedItemColor:
              Colors.white24,

          selectedFontSize: 10,

          unselectedFontSize: 10,

          iconSize: 24,

          showSelectedLabels: true,

          showUnselectedLabels: true,

          selectedLabelStyle:
              const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            height: 2,
          ),

          unselectedLabelStyle:
              const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            height: 2,
          ),

          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
              ),
              label: 'HOME',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.history_rounded,
              ),
              label: 'HISTORY',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.psychology_rounded,
              ),
              label: 'COACH',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.analytics_rounded,
              ),
              label: 'STATS',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_rounded,
              ),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}