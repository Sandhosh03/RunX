import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PRIVACY POLICY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Last Updated', 'June 1, 2026'),
            _buildSection('Data Collection', 'We collect biometrics, location (GPS), and account information to provide elite fitness tracking.'),
            _buildSection('Location Usage', 'Precise location is used to map your runs. Background location is used only during active run sessions.'),
            _buildSection('Security', 'Data is encrypted and stored securely via Supabase. We never sell your data.'),
            _buildSection('Contact', 'For data requests, contact support@runx.fit.'),
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
