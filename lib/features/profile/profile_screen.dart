import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../models/goal_data.dart';
import '../../models/xp_data.dart';
import '../../models/run_session.dart';
import '../../services/profile_service.dart';
import '../../services/goal_service.dart';
import '../../services/xp_service.dart';
import '../../services/run_storage_service.dart';
import '../../widgets/xp_progress_card.dart';
import '../../widgets/level_badge.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_screen.dart';
import '../../widgets/animations/fade_slide_animation.dart';
import '../../widgets/animations/shimmer_loading.dart';
import '../../widgets/premium/premium_card.dart';

import '../../services/achievement_service.dart';
import '../../services/challenge_service.dart';
import '../../services/auth_service.dart';
import '../../models/achievement.dart';
import '../../models/challenge.dart';
import '../../widgets/achievement_card.dart';
import '../../widgets/challenge_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController dailyDistanceController = TextEditingController();
  final TextEditingController dailyCaloriesController = TextEditingController();

  bool isLoading = true;
  UserProfile? currentProfile;
  XpData? xpData;
  List<RunSession> allRuns = [];
  List<Achievement> achievements = [];
  List<Challenge> challenges = [];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    goalController.dispose();
    dailyDistanceController.dispose();
    dailyCaloriesController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final profile = await ProfileService.getProfile();
    final goals = await GoalService.getGoals();
    final loadedXp = await XpService.getXpData();
    final runs = await RunStorageService.getRuns();

    String displayName = 'Runner';

    if (profile != null) {
      currentProfile = profile;
      nameController.text = profile.name;
      ageController.text = profile.age.toString();
      weightController.text = profile.weight.toString();
      heightController.text = profile.height.toString();
      goalController.text = profile.goal;
      displayName = profile.name;
    } else {
      // Fallback to auth metadata if profile record doesn't exist yet
      final authName = await AuthService.getUserName();
      if (authName != null) {
        displayName = authName;
        // Pre-fill the controller for consistency
        nameController.text = authName;
      }
    }

    dailyDistanceController.text = goals.dailyDistanceGoal.toString();
    dailyCaloriesController.text = goals.dailyCaloriesGoal.toString();

    final loadedAchievements = AchievementService.generateAchievements(runs);
    final loadedChallenges = ChallengeService.generateChallenges(runs);

    if (!mounted) return;

    setState(() {
      xpData = loadedXp;
      allRuns = runs;
      achievements = loadedAchievements;
      challenges = loadedChallenges;
      currentProfile ??= UserProfile(
        name: displayName,
        age: 25,
        weight: 70,
        height: 175,
        goal: 'Get Fit',
      );
      isLoading = false;
    });
  }

  Widget _buildSkeletonProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ShimmerLoading(
        isLoading: true,
        child: Column(
          children: [
            const Center(child: SkeletonBox(width: 100, height: 100, borderRadius: 50)),
            const SizedBox(height: 15),
            const Center(child: SkeletonBox(width: 150, height: 30)),
            const SizedBox(height: 25),
            const SkeletonBox(height: 120, borderRadius: 24),
            const SizedBox(height: 30),
            const SkeletonBox(height: 150, borderRadius: 28),
            const SizedBox(height: 30),
            const SkeletonBox(height: 300, borderRadius: 28),
          ],
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    final profile = (currentProfile ??
            UserProfile(
              name: 'Runner',
              age: 25,
              weight: 70,
              height: 175,
              goal: 'Get Fit',
            ))
        .copyWith(
      name: nameController.text,
      age: int.tryParse(ageController.text) ?? 0,
      weight: double.tryParse(weightController.text) ?? 0,
      height: double.tryParse(heightController.text) ?? 175,
      goal: goalController.text,
    );

    final goals = GoalData(
      dailyDistanceGoal: double.tryParse(dailyDistanceController.text) ?? 5,
      dailyCaloriesGoal: double.tryParse(dailyCaloriesController.text) ?? 500,
    );

    await ProfileService.saveProfile(profile);
    await GoalService.saveGoals(goals);

    setState(() {
      currentProfile = profile;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile & Goals Saved', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary.withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  double _calculateBMI() {
    double weight = double.tryParse(weightController.text) ?? 70.0;
    double heightCm = double.tryParse(heightController.text) ?? 175.0;
    if (heightCm == 0) return 0;
    double heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  int _calculateFitnessScore() {
    int baseScore = 500;
    int runsScore = allRuns.length * 50;
    int levelScore = (xpData?.level ?? 1) * 100;
    double bmiDiff = (_calculateBMI() - 22.0).abs();
    int penalty = (bmiDiff * 10).round();
    
    int finalScore = baseScore + runsScore + levelScore - penalty;
    return finalScore > 0 ? finalScore : 0;
  }

  String _getRankTitle() {
    int level = xpData?.level ?? 1;
    if (level < 5) return 'Novice Runner';
    if (level < 10) return 'Consistent Athlete';
    if (level < 20) return 'Advanced Pacer';
    return 'Elite Marathoner';
  }

  double _calculateTotalDistance() {
    double total = 0;
    for (var run in allRuns) {
      total += run.distance;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => loadProfile()); // reload if personal info changed
            },
            icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? _buildSkeletonProfile()
          : RefreshIndicator(
              onRefresh: loadProfile,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 100),
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.black,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (xpData != null)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: LevelBadge(level: xpData!.level, size: 36),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 150),
                      child: Column(
                        children: [
                          Text(
                            currentProfile?.name ?? 'Runner',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _getRankTitle().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    if (xpData != null)
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: XpProgressCard(xpData: xpData!, showHeader: false),
                      ),
                    const SizedBox(height: 30),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 300),
                      child: PremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'ATHLETE BIOMETRICS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailItem('GENDER', currentProfile?.gender ?? '---'),
                                _buildDetailItem('AGE', '${currentProfile?.age ?? '---'}'),
                                _buildDetailItem('LEVEL', currentProfile?.fitnessLevel.toUpperCase() ?? '---'),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailItem('HEIGHT', '${currentProfile?.height.toInt() ?? '---'} CM'),
                                _buildDetailItem('WEIGHT', '${currentProfile?.weight.toInt() ?? '---'} KG'),
                                _buildDetailItem('BMI', _calculateBMI().toStringAsFixed(1)),
                              ],
                            ),
                            const SizedBox(height: 25),
                            const Divider(color: AppColors.outline),
                            const SizedBox(height: 10),
                            const Text(
                              'RUNNING GOAL',
                              style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentProfile?.goal.toUpperCase() ?? '---',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 350),
                      child: PremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.military_tech_outlined, color: AppColors.primary),
                                    const SizedBox(width: 10),
                                    Text(
                                      'FITNESS SCORE',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (allRuns.isEmpty)
                              const Column(
                                children: [
                                  Center(
                                    child: Text(
                                      '---',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white24,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Center(
                                    child: Text(
                                      'COMPLETE RUNS TO UNLOCK',
                                      style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${_calculateFitnessScore()}',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Center(
                                    child: Text(
                                      'BASED ON BIOMETRICS AND CONSISTENCY',
                                      style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 20),
                            const Divider(color: AppColors.outline),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: _buildSummaryMetric('RUNS', '${allRuns.length}')),
                                Expanded(child: _buildSummaryMetric('KM', _calculateTotalDistance().toStringAsFixed(1))),
                                Expanded(child: _buildSummaryMetric('LVL', '${xpData?.level ?? 1}')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 350),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MONTHLY CHALLENGES',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ...challenges.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: ChallengeCard(challenge: c),
                          )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EARNED BADGES',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ...achievements.where((a) => a.unlocked).map((a) => AchievementCard(achievement: a)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}



