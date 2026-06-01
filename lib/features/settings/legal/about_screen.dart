import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/premium/premium_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ABOUT RUNX', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: const Icon(Icons.directions_run_rounded, color: AppColors.primary, size: 50),
                  ),
                  const SizedBox(height: 20),
                  const Text('RunX', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const Text('VERSION 1.0.0', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('THE VISION', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  SizedBox(height: 10),
                  Text(
                    'RunX is a premium monochrome fitness platform designed for elite performance. Our mission is to strip away the noise and focus on pure, data-driven excellence.',
                    style: TextStyle(color: Colors.white70, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.outline),
            const SizedBox(height: 20),
            _buildInfoRow('DEVELOPER', 'RunX Team'),
            _buildInfoRow('SUPPORT', 'support@runx.fit'),
            _buildInfoRow('LICENSE', 'Open Source (MIT)'),
            const SizedBox(height: 40),
            const Text(
              'MADE FOR THE DRIVEN.',
              style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
