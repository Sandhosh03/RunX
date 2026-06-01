import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/app_settings.dart';
import '../../services/auth_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/settings_tile.dart';
import '../auth/login_screen.dart';
import 'personal_info_screen.dart';
import 'legal/privacy_policy_screen.dart';
import 'legal/terms_screen.dart';
import 'legal/about_screen.dart';
import 'legal/support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings settings = AppSettings();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedSettings = await SettingsService.getSettings();
    setState(() {
      settings = loadedSettings;
      isLoading = false;
    });
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() {
      settings = newSettings;
    });
    await SettingsService.saveSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader('Account'),
                _buildAccountInfo(),
                const SizedBox(height: 15),
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  subtitle: 'Age, weight, goals & targets',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                    );
                  },
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 14),
                ),
                const SizedBox(height: 30),

                _buildSectionHeader('Preferences'),
                SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: isDark ? 'System follows dark theme' : 'System follows light theme',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                SettingsTile(
                  icon: Icons.straighten_rounded,
                  title: 'Distance Units',
                  subtitle: settings.isMetric ? 'Metric (KM)' : 'Imperial (Miles)',
                  trailing: Switch(
                    value: settings.isMetric,
                    onChanged: (val) => _updateSettings(settings.copyWith(isMetric: val)),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                SettingsTile(
                  icon: Icons.map_rounded,
                  title: 'Auto-Follow Map',
                  subtitle: 'Keep tracker centered',
                  trailing: Switch(
                    value: settings.autoFollowMap,
                    onChanged: (val) => _updateSettings(settings.copyWith(autoFollowMap: val)),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Enable alerts',
                  trailing: Switch(
                    value: settings.notificationsEnabled,
                    onChanged: (val) => _updateSettings(settings.copyWith(notificationsEnabled: val)),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 30),

                _buildSectionHeader('Support & Legal'),
                SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SupportScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About RunX',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    );
                  },
                  trailing: Text('v1.0.0', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                ),
                const SizedBox(height: 40),

                OutlinedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.outline),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildAccountInfo() {
    return FutureBuilder<String?>(
      future: AuthService.getUserName(),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Runner';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.black, size: 35),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                    ),
                    Text(
                      AuthService.userEmail ?? 'No email linked',
                      style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.outline)),
        title: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: const Text('Are you sure you want to logout? your session will be ended.', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900))),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
