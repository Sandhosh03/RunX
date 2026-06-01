import 'package:flutter/material.dart';
import '../models/run_session.dart';
import '../features/history/run_detail_screen.dart';
import 'premium/premium_card.dart';

class HistoryCard extends StatelessWidget {
  final RunSession session;

  const HistoryCard({
    super.key,
    required this.session,
  });

  String formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return hours == '00' ? '$minutes:$secs' : '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RunDetailScreen(session: session),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                session.date.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 12,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Hero(
                tag: 'distance_${session.date}_${session.duration}',
                child: Material(
                  color: Colors.transparent,
                  child: _metric(
                    'DISTANCE',
                    '${session.distance.toStringAsFixed(2)} KM',
                  ),
                ),
              ),
              _metric(
                'KCAL',
                session.calories.toStringAsFixed(0),
              ),
              _metric(
                'TIME',
                formatDuration(session.duration),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

