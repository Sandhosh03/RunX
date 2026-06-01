import 'package:flutter/material.dart';
import '../features/tracking/tracking_screen.dart';
import '../core/theme/app_colors.dart';

class TodaysGoalCard extends StatelessWidget {
  const TodaysGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: AppColors.outline,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'TODAY\'S GOAL',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),

          const SizedBox(height: 15),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                '10',
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),

              SizedBox(width: 8),

              Padding(
                padding: EdgeInsets.only(bottom: 8),

                child: Text(
                  'KM',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'PROGRESS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              Text(
                '52%',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: 0.52,

            backgroundColor: AppColors.outline,

            valueColor: const AlwaysStoppedAnimation(
              AppColors.primary,
            ),

            minHeight: 6,

            borderRadius: BorderRadius.circular(3),
          ),

          const SizedBox(height: 15),

          const Text(
            '5.2 KM COMPLETED',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrackingScreen(),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,

                foregroundColor: Colors.black,

                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              child: const Text(
                'START RUN',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}