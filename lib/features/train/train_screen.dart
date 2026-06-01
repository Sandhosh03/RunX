import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/animations/fade_slide_animation.dart';
import '../../widgets/premium/premium_card.dart';
import '../../models/training_plan.dart';
import '../../services/training_plan_service.dart';
import '../../services/profile_service.dart';
import '../../services/run_storage_service.dart';
import '../../models/user_profile.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  bool _isLoading = true;
  bool _isSelectingPlan = false;
  TrainingPlan? _activePlan;
  UserProfile? _profile;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final plan = await TrainingPlanService.getActivePlan();
    final profile = await ProfileService.getProfile();
    
    Map<String, dynamic> stats = {
      'adherence': 0.0,
      'consistency': 0.0,
      'completion': 0.0,
      'completed': 0,
      'totalWorkouts': 0,
    };

    if (plan != null) {
      stats = PlanProgressTracker.calculateStats(plan);
    }

    if (!mounted) return;
    setState(() {
      _activePlan = plan;
      _profile = profile;
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _generateNewPlan({PlanType? forceType}) async {
    setState(() {
      _isLoading = true;
      _isSelectingPlan = false;
    });
    
    final runs = await RunStorageService.getRuns();
    double weeklyAvg = 0;
    if (runs.isNotEmpty) {
      double total = runs.fold(0, (sum, run) => sum + run.distance);
      weeklyAvg = total / 4; 
    }

    if (_profile != null) {
      TrainingPlan newPlan;
      if (forceType != null) {
        // Mock generation for specific type
        newPlan = TrainingPlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _getPlanName(forceType),
          description: "Personalized path to elite performance.",
          type: forceType,
          totalWeeks: forceType == PlanType.halfMarathon ? 12 : 8,
          startDate: DateTime.now(),
          schedule: PlanRecommendationEngine.generateRecommendation(_profile!, weeklyAvg).schedule, // In real app, re-generate based on type
        );
      } else {
        newPlan = PlanRecommendationEngine.generateRecommendation(_profile!, weeklyAvg);
      }
      
      await TrainingPlanService.savePlan(newPlan);
      await _loadData();
    }
  }

  String _getPlanName(PlanType type) {
    switch (type) {
      case PlanType.beginner: return "Zero to Runner";
      case PlanType.fiveK: return "5K PR Crusher";
      case PlanType.tenK: return "10K Power";
      case PlanType.halfMarathon: return "Half Marathon Prep";
      case PlanType.weightLoss: return "Weight Loss Journey";
      case PlanType.endurance: return "Endurance Builder";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('TRAINING', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)),
        actions: [
          if (_activePlan != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
              onPressed: () => setState(() => _isSelectingPlan = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _isSelectingPlan 
                ? _buildPlanSelectionView()
                : (_activePlan == null ? _buildNoPlanView() : _buildActivePlanView()),
            ),
    );
  }

  Widget _buildNoPlanView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FadeSlideAnimation(
          delay: Duration(milliseconds: 100),
          child: PremiumCard(
            child: Column(
              children: [
                Icon(Icons.directions_run_rounded, color: AppColors.primary, size: 60),
                SizedBox(height: 20),
                Text(
                  'SMART TRAINING PLANS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Let the AI Coach generate a personalized schedule to reach your goals faster and safer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, height: 1.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        FadeSlideAnimation(
          delay: const Duration(milliseconds: 200),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => setState(() => _isSelectingPlan = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('EXPLORE PLANS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => setState(() => _isSelectingPlan = false),
            ),
            const Text('CHOOSE YOUR PATH', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
        const SizedBox(height: 20),
        ...PlanType.values.map((type) => FadeSlideAnimation(
          delay: const Duration(milliseconds: 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: InkWell(
              onTap: () => _generateNewPlan(forceType: type),
              child: PremiumCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.outline,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPlanName(type).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPlanDescription(type),
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                  ],
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  String _getPlanDescription(PlanType type) {
    switch (type) {
      case PlanType.beginner: return "For those starting their journey.";
      case PlanType.fiveK: return "Master the 5km distance.";
      case PlanType.tenK: return "Double your endurance.";
      case PlanType.halfMarathon: return "The ultimate distance challenge.";
      case PlanType.weightLoss: return "Burn fat through consistent cardio.";
      case PlanType.endurance: return "Build a massive aerobic engine.";
    }
  }

  Widget _buildActivePlanView() {
    final todaySession = _activePlan!.getTodaySession();
    final double progress = _activePlan!.progressPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideAnimation(
          delay: const Duration(milliseconds: 100),
          child: PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACTIVE PLAN',
                            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _activePlan!.name.toUpperCase(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24),
                      onPressed: () async {
                        await TrainingPlanService.clearPlan();
                        _loadData();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPlanStat('WEEK', '${_activePlan!.currentWeek}/${_activePlan!.totalWeeks}'),
                    _buildPlanStat('ADHERENCE', '${_stats['adherence'].toStringAsFixed(0)}%'),
                    _buildPlanStat('CONSISTENCY', '${_stats['consistency'].toStringAsFixed(0)}%'),
                    _buildPlanStat('PROGRESS', '${_stats['completion'].toStringAsFixed(0)}%'),
                  ],
                ),
                const SizedBox(height: 25),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.outline,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        const Text(
          'TODAY\'S WORKOUT',
          style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 15),
        
        FadeSlideAnimation(
          delay: const Duration(milliseconds: 200),
          child: todaySession != null
              ? _buildSessionCard(todaySession, isToday: true)
              : const PremiumCard(
                  child: Center(
                    child: Text('REST DAY', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2)),
                  ),
                ),
        ),

        const SizedBox(height: 40),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'WEEKLY SCHEDULE',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            Text(
              'WEEK ${_activePlan!.currentWeek}',
              style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 15),
        
        ..._activePlan!.schedule
            .where((s) => s.week == _activePlan!.currentWeek)
            .map((s) => FadeSlideAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: _buildSessionCard(s, isToday: s.day == ((DateTime.now().difference(_activePlan!.startDate).inDays % 7) + 1)),
                )),
      ],
    );
  }

  Widget _buildPlanStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildSessionCard(TrainingSession session, {required bool isToday}) {
    final bool isPast = (session.week - 1) * 7 + (session.day - 1) < (DateTime.now().difference(_activePlan!.startDate).inDays);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outline,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: session.isCompleted ? AppColors.primary : (isPast ? AppColors.outline : Colors.transparent),
              shape: BoxShape.circle,
              border: Border.all(color: session.isCompleted ? AppColors.primary : AppColors.outline, width: 2),
            ),
            child: Center(
              child: session.isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.black, size: 18)
                  : Text('D${session.day}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: isPast ? Colors.white24 : Colors.white)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.title.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: session.isCompleted || !isPast ? Colors.white : Colors.white38,
                      ),
                    ),
                    if (session.type != SessionType.rest)
                      Text(
                        session.targetDistanceKm > 0 
                          ? '${session.targetDistanceKm} KM'
                          : '${session.targetDurationMinutes} MIN',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  session.description,
                  style: TextStyle(
                    color: session.isCompleted || !isPast ? Colors.white54 : Colors.white24,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isToday && !session.isCompleted && session.type != SessionType.rest) ...[
            const SizedBox(width: 15),
            IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
              onPressed: () async {
                await TrainingPlanService.markSessionComplete(session.id);
                _loadData();
              },
            ),
          ]
        ],
      ),
    );
  }
}
