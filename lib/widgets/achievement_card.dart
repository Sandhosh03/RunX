import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../core/theme/app_colors.dart';

class AchievementCard
    extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      padding: const EdgeInsets.all(
        16,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.unlocked
                  ? AppColors.primary
                  : AppColors.outline,
          width: achievement.unlocked ? 1.5 : 1,
        ),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: achievement.unlocked ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              achievement.icon,
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  achievement.title.toUpperCase(),

                  style: TextStyle(
                    fontSize: 14,

                    fontWeight:
                        FontWeight.w900,

                    letterSpacing: 1,

                    color:
                        achievement
                                .unlocked
                            ? AppColors.primary
                            : Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  achievement.description,

                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            achievement.unlocked
                ? Icons.check_circle_rounded
                : Icons.lock_outline_rounded,

            color:
                achievement.unlocked
                    ? AppColors.primary
                    : Colors.white24,
            size: 20,
          ),
        ],
      ),
    );
  }
}