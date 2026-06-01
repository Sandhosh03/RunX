import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/run_storage_service.dart';
import '../../services/streak_service.dart';
import '../../services/profile_service.dart';
import '../../services/goal_service.dart';
import '../../services/coach_service.dart';
import '../../models/coach_data.dart';
import '../../widgets/animations/fade_slide_animation.dart';
import '../../widgets/premium/premium_card.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  bool _isLoading = true;
  CoachInsight? _dailyInsight;
  CoachPerformanceAnalysis? _weeklyAnalysis;
  List<CoachRecommendation> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadCoachData();
  }

  Future<void> _loadCoachData() async {
    final runs = await RunStorageService.getRuns();
    final profile = await ProfileService.getProfile();
    final goals = await GoalService.getGoals();
    final streak = StreakService.calculateStreak(runs);

    if (!mounted) return;

    setState(() {
      _dailyInsight = InsightEngine.generateDailyInsight(
        runs: runs,
        streak: streak,
        profile: profile,
      );
      _weeklyAnalysis = InsightEngine.analyzeWeeklyPerformance(runs);
      _recommendations = RecommendationEngine.getRecommendations(
        runs: runs,
        goals: goals,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI COACH', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_dailyInsight != null)
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 100),
                      child: _buildInsightCard(_dailyInsight!),
                    ),
                  
                  const SizedBox(height: 30),
                  
                  if (_weeklyAnalysis != null)
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: _buildAnalysisCard(_weeklyAnalysis!),
                    ),
                  
                  const SizedBox(height: 30),
                  
                  const Text(
                    'COACH RECOMMENDATIONS',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  ...List.generate(_recommendations.length, (index) {
                    return FadeSlideAnimation(
                      delay: Duration(milliseconds: 300 + (index * 100)),
                      child: _buildRecommendationTile(_recommendations[index]),
                    );
                  }),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildInsightCard(CoachInsight insight) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(insight.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                insight.title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            insight.message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: AppColors.outline),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                'AI Analysis based on recent history',
                style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(CoachPerformanceAnalysis analysis) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WEEKLY PERFORMANCE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('MILEAGE', '${analysis.weeklyMileage.toStringAsFixed(1)} KM'),
              _buildStat('AVG PACE', _formatPace(analysis.averagePace)),
              _buildStat('RUNS', '${analysis.runCount}'),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'CONSISTENCY SCORE',
            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: analysis.consistencyScore,
              minHeight: 6,
              backgroundColor: AppColors.outline,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            analysis.summary,
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      ],
    );
  }

  Widget _buildRecommendationTile(CoachRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.description,
                  style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          TextButton(
            onPressed: rec.onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              rec.actionLabel,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPace(double pace) {
    if (pace == 0) return "--:--";
    int paceMinutes = pace.floor();
    int paceSeconds = ((pace - paceMinutes) * 60).round();
    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}';
  }
}
