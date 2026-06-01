import 'package:flutter/material.dart';

import '../../models/run_session.dart';
import '../../models/streak_data.dart';
import '../../models/goal_data.dart';
import '../../models/user_profile.dart';
import '../../models/xp_data.dart';
import '../../models/fitness_insight.dart';

import '../../services/run_storage_service.dart';
import '../../services/streak_service.dart';
import '../../services/goal_service.dart';
import '../../services/profile_service.dart';
import '../../services/xp_service.dart';
import '../../services/insight_service.dart';

import '../../widgets/stats_card.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/xp_progress_card.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/weekly_summary_card.dart';
import '../../widgets/animations/fade_slide_animation.dart';
import '../../widgets/animations/shimmer_loading.dart';
import '../../widgets/premium/premium_card.dart';
import '../../core/theme/app_colors.dart';

import '../../utils/app_spacing.dart';
import '../tracking/tracking_screen.dart';
import '../statistics/analytics_screen.dart';

import '../../services/challenge_service.dart';
import '../../widgets/challenge_card.dart';
import '../community/community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RunSession> runs = [];
  bool isLoading = true;
  double totalDistance = 0;
  double totalCalories = 0;
  int totalRuns = 0;
  RunSession? latestRun;
  StreakData? streakData;
  GoalData? goalData;
  UserProfile? userProfile;
  XpData? xpData;
  List<FitnessInsight> insights = [];
  Map<String, dynamic> weeklySummary = {};

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final loadedRuns = await RunStorageService.getRuns();
    final loadedGoals = await GoalService.getGoals();
    final loadedProfile = await ProfileService.getProfile();
    final loadedXp = await XpService.getXpData();

    double distance = 0;
    double calories = 0;

    for (var run in loadedRuns) {
      distance += run.distance;
      calories += run.calories;
    }

    final calculatedStreak = StreakService.calculateStreak(loadedRuns);

    final generatedInsights = InsightService.generateInsights(
      runs: loadedRuns,
      streakData: calculatedStreak,
      goalData: loadedGoals,
      xpData: loadedXp,
      todayDistance: distance,
      todayCalories: calories,
    );

    final summary = InsightService.calculateWeeklySummary(loadedRuns);

    if (!mounted) return;

    setState(() {
      runs = loadedRuns;
      totalRuns = loadedRuns.length;
      totalDistance = distance;
      totalCalories = calories;
      goalData = loadedGoals;
      userProfile = loadedProfile;
      xpData = loadedXp;
      insights = generatedInsights;
      weeklySummary = summary;

      if (loadedRuns.isNotEmpty) {
        latestRun = loadedRuns.first;
      }

      streakData = calculatedStreak;
      isLoading = false;
    });
  }

  Widget _buildSkeletonDashboard() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ShimmerLoading(
            isLoading: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonBox(width: 100, height: 16),
                        SizedBox(height: 8),
                        SkeletonBox(width: 150, height: 28),
                      ],
                    ),
                    const SkeletonBox(width: 80, height: 40, borderRadius: 20),
                  ],
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                const SkeletonBox(height: 150, borderRadius: 24),
                const SizedBox(height: AppSpacing.sectionGap),
                const SkeletonBox(height: 120, borderRadius: 24),
                const SizedBox(height: AppSpacing.sectionGap),
                const SkeletonBox(height: 80, borderRadius: 28),
                const SizedBox(height: AppSpacing.sectionGap),
                const SkeletonBox(height: 200, borderRadius: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distanceGoal = goalData?.dailyDistanceGoal ?? 5;
    final caloriesGoal = goalData?.dailyCaloriesGoal ?? 500;
    final distanceProgress = (totalDistance / distanceGoal).clamp(0, 1);
    final caloriesProgress = (totalCalories / caloriesGoal).clamp(0, 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? _buildSkeletonDashboard()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DashboardHeader(profile: userProfile),
                            const SizedBox(height: AppSpacing.smallGap),
                            const Text(
                              'Run Beyond Limits',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      
                      if (insights.isNotEmpty) ...[
                        FadeSlideAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personalized Insights',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                height: 170,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: insights.length,
                                  itemBuilder: (context, index) => InsightCard(insight: insights[index]),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sectionGap),
                            ],
                          ),
                        ),
                      ],

                      if (xpData != null) ...[
                        FadeSlideAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              XpProgressCard(xpData: xpData!),
                              const SizedBox(height: AppSpacing.sectionGap),
                            ],
                          ),
                        ),
                      ],
                      // Start Run Button
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 400),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrackingScreen(),
                                  ),
                                ).then((_) => loadDashboardData());
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 22),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, color: Colors.black, size: 30),
                                    SizedBox(width: 10),
                                    Text(
                                      'START RUN',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sectionGap),
                          ],
                        ),
                      ),

                      if (weeklySummary.isNotEmpty) ...[
                        FadeSlideAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
                              WeeklySummaryCard(
                                distance: (weeklySummary['distance'] as num).toDouble(),
                                calories: (weeklySummary['calories'] as num).toDouble(),
                                count: weeklySummary['count'] as int,
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.analytics_outlined, color: Colors.white54),
                                  label: const Text(
                                    'VIEW DETAILED ANALYTICS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: AppColors.outline),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sectionGap),
                            ],
                          ),
                        ),
                      ],

                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 600),
                        child: PremiumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'DAILY GOALS',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              const Text(
                                'DISTANCE GOAL',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: distanceProgress.toDouble(),
                                  minHeight: 8,
                                  backgroundColor: AppColors.outline,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${totalDistance.toStringAsFixed(1)} / ${distanceGoal.toStringAsFixed(1)} KM',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const SizedBox(height: 25),
                              const Text(
                                'CALORIES GOAL',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: caloriesProgress.toDouble(),
                                  minHeight: 8,
                                  backgroundColor: AppColors.outline,
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.white70,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${totalCalories.toStringAsFixed(0)} / ${caloriesGoal.toStringAsFixed(0)} KCAL',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 700),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              StatsCard(
                                title: 'DISTANCE',
                                value: '${totalDistance.toStringAsFixed(1)} KM',
                              ),
                              const SizedBox(width: AppSpacing.itemGap),
                              StatsCard(
                                title: 'RUNS',
                                value: '$totalRuns',
                              ),
                              const SizedBox(width: AppSpacing.itemGap),
                              StatsCard(
                                title: 'CALORIES',
                                value: totalCalories.toStringAsFixed(0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 800),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'RECENT ACTIVITY',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                      color: Colors.white54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'VIEW ALL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.itemGap),
                            if (latestRun != null)
                              ActivityCard(
                                title: 'LATEST RUN',
                                subtitle: '${latestRun!.distance.toStringAsFixed(2)} KM • ${latestRun!.date}',
                                icon: Icons.directions_run_rounded,
                              )
                            else
                              const ActivityCard(
                                title: 'NO RUNS YET',
                                subtitle: 'Start your first run today',
                                icon: Icons.directions_run_rounded,
                              ),
                            const SizedBox(height: AppSpacing.sectionGap),
                            PremiumCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_rounded,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'STREAK PROGRESS',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '${streakData?.currentStreak ?? 0} DAYS STREAK',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'LONGEST STREAK: ${streakData?.longestStreak ?? 0} DAYS',
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FEATURED CHALLENGE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.white54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 15),
                            if (runs.isNotEmpty)
                               ChallengeCard(challenge: ChallengeService.generateChallenges(runs)[0]),
                            const SizedBox(height: AppSpacing.sectionGap),
                            PremiumCard(
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'EXPLORE COMMUNITIES',
                                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Find your pack and run together.',
                                          style: TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CommunityScreen()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('EXPLORE', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}




