import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('TERMS & CONDITIONS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Acceptance', 'By using RunX, you agree to these terms and our safety guidelines.'),
            _buildSection('Health Warning', 'Fitness tracking involves physical exertion. Consult a doctor before use. RunX is not liable for injuries.'),
            _buildSection('Account Responsibility', 'You are responsible for your account security and the content you share in communities.'),
            _buildSection('Modifications', 'We may update these terms to reflect new features or regulations.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14)),
        ],
      ),
    );
  }
}
