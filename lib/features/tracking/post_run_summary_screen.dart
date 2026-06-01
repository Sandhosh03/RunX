import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/run_session.dart';
import '../../widgets/animations/fade_slide_animation.dart';
import '../../widgets/premium/premium_card.dart';

class PostRunSummaryScreen extends StatelessWidget {
  final RunSession session;
  final int earnedXp;
  final bool leveledUp;
  final int newLevel;

  const PostRunSummaryScreen({
    super.key,
    required this.session,
    required this.earnedXp,
    required this.leveledUp,
    required this.newLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const FadeSlideAnimation(
                    delay: Duration(milliseconds: 200),
                    child: Text(
                      'RUN COMPLETE',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const FadeSlideAnimation(
                    delay: Duration(milliseconds: 300),
                    child: Text(
                      'Outstanding performance!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Main Stats Grid
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatBox('DISTANCE', session.distance.toStringAsFixed(2), 'KM'),
                        _buildStatBox('DURATION', _formatDuration(session.duration), ''),
                        _buildStatBox('AVG PACE', _formatPace(session.averagePace ?? 0), 'MIN/KM'),
                        _buildStatBox('CALORIES', session.calories.toStringAsFixed(0), 'KCAL'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // XP Progress
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 500),
                    child: PremiumCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 30),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '+$earnedXp XP EARNED',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  'You are getting stronger!',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (leveledUp)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'LVL $newLevel',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Map Snapshot Placeholder
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 600),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_rounded, color: Colors.white24, size: 50),
                            SizedBox(height: 10),
                            Text(
                              'ROUTE SNAPSHOT',
                              style: TextStyle(
                                color: Colors.white24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 700),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'SAVE & CONTINUE',
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.share_rounded, size: 20),
                                label: const Text('SHARE'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: AppColors.outline),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white54,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: const Text('DISCARD', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ],
                  ),
                  ),
                  ),
                  ],
                  ),
                  );
                  }

                  Widget _buildStatBox(String label, String value, String unit) {
                  return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                  Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Text(
                  unit,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54),
                  ),
                  ],
                  ),
                  ],
                  ),
                  );
                  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _formatPace(double pace) {
    int paceMinutes = pace.floor();
    int paceSeconds = ((pace - paceMinutes) * 60).round();
    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}';
  }
}
