import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/premium/premium_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('HELP & SUPPORT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FREQUENTLY ASKED QUESTIONS', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 20),
            _buildFaq('How is my pace calculated?', 'We use a rolling average of GPS coordinates to ensure smooth and accurate pace tracking even in urban environments.'),
            _buildFaq('Does RunX work offline?', 'Yes. Your runs and profile are cached locally and will sync automatically when you reconnect.'),
            _buildFaq('How do I join a community?', 'Navigate to the Explore tab to find and follow community packs.'),
            const SizedBox(height: 30),
            const Divider(color: AppColors.outline),
            const SizedBox(height: 30),
            const Text('CONTACT US', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 20),
            PremiumCard(
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.primary),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EMAIL SUPPORT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        Text('support@runx.fit', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaq(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
          const SizedBox(height: 8),
          Text(answer, style: const TextStyle(color: Colors.white54, height: 1.5, fontSize: 13)),
        ],
      ),
    );
  }
}
