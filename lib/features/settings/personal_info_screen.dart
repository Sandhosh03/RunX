import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../../models/goal_data.dart';
import '../../services/profile_service.dart';
import '../../services/goal_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/animations/fade_slide_animation.dart';
import '../../widgets/premium/premium_card.dart';

import '../navigation/main_navigation.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController dailyDistanceController = TextEditingController();
  final TextEditingController dailyCaloriesController = TextEditingController();
  
  String selectedGender = 'Other';
  String selectedFitnessLevel = 'Beginner';

  bool isLoading = true;
  UserProfile? currentProfile;
  GoalData? currentGoals;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    goalController.dispose();
    dailyDistanceController.dispose();
    dailyCaloriesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final profile = await ProfileService.getProfile();
    final goals = await GoalService.getGoals();

    if (profile != null) {
      currentProfile = profile;
      nameController.text = profile.name;
      ageController.text = profile.age > 0 ? profile.age.toString() : '';
      weightController.text = profile.weight > 0 ? profile.weight.toString() : '';
      heightController.text = profile.height > 0 ? profile.height.toString() : '';
      goalController.text = profile.goal;
      selectedGender = profile.gender;
      selectedFitnessLevel = profile.fitnessLevel;
    } else {
      // Initialize with default if absolutely nothing exists
      nameController.text = await AuthService.getUserName() ?? 'Runner';
    }

    currentGoals = goals;
    dailyDistanceController.text = goals.dailyDistanceGoal.toString();
    dailyCaloriesController.text = goals.dailyCaloriesGoal.toString();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveData() async {
    if (nameController.text.isEmpty || 
        ageController.text.isEmpty || 
        weightController.text.isEmpty || 
        heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    final updatedProfile = (currentProfile ??
            UserProfile(
              name: nameController.text,
              age: int.tryParse(ageController.text) ?? 25,
              weight: double.tryParse(weightController.text) ?? 70,
              height: double.tryParse(heightController.text) ?? 175,
              goal: goalController.text.isEmpty ? 'Get Fit' : goalController.text,
            ))
        .copyWith(
      name: nameController.text,
      age: int.tryParse(ageController.text) ?? 0,
      weight: double.tryParse(weightController.text) ?? 0,
      height: double.tryParse(heightController.text) ?? 0,
      goal: goalController.text,
      gender: selectedGender,
      fitnessLevel: selectedFitnessLevel,
    );

    final updatedGoals = GoalData(
      dailyDistanceGoal: double.tryParse(dailyDistanceController.text) ?? 5,
      dailyCaloriesGoal: double.tryParse(dailyCaloriesController.text) ?? 500,
    );

    await ProfileService.saveProfile(updatedProfile);
    await GoalService.saveGoals(updatedGoals);

    if (!mounted) return;
    
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Setup Complete'),
        backgroundColor: AppColors.primary,
      ),
    );
    
    // If we're coming from the splash/auth flow, we might want to push to Home
    // If we're in settings, we pop.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ATHLETE PROFILE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        automaticallyImplyLeading: Navigator.canPop(context),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveData,
            child: const Text('SAVE', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('BASIC BIOMETRICS'),
                          const SizedBox(height: 20),
                          _buildField(controller: nameController, label: 'FULL NAME'),
                          Row(
                            children: [
                              Expanded(child: _buildField(controller: ageController, label: 'AGE', keyboard: TextInputType.number)),
                              const SizedBox(width: 15),
                              Expanded(child: _buildDropdown('GENDER', ['Male', 'Female', 'Non-Binary', 'Other'], selectedGender, (val) => setState(() => selectedGender = val!))),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildField(controller: heightController, label: 'HEIGHT (CM)', keyboard: TextInputType.number)),
                              const SizedBox(width: 15),
                              Expanded(child: _buildField(controller: weightController, label: 'WEIGHT (KG)', keyboard: TextInputType.number)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('TRAINING FOCUS'),
                          const SizedBox(height: 20),
                          _buildField(controller: goalController, label: 'RUNNING GOAL'),
                          _buildDropdown('FITNESS LEVEL', ['Beginner', 'Intermediate', 'Advanced', 'Elite'], selectedFitnessLevel, (val) => setState(() => selectedFitnessLevel = val!)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('DAILY TARGETS'),
                          const SizedBox(height: 20),
                          _buildField(controller: dailyDistanceController, label: 'DISTANCE GOAL (KM)', keyboard: TextInputType.number),
                          _buildField(controller: dailyCaloriesController, label: 'CALORIES GOAL', keyboard: TextInputType.number),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, required String label, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.outline)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.outline)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String current, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: current,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
