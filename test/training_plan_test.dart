import 'package:flutter_test/flutter_test.dart';
import 'package:runx/models/training_plan.dart';
import 'package:runx/models/user_profile.dart';
import 'package:runx/services/plan_recommendation_engine.dart';
import 'package:runx/services/plan_progress_tracker.dart';

void main() {
  group('PlanRecommendationEngine Tests', () {
    final mockProfile = UserProfile(
      name: 'Test Runner',
      age: 30,
      weight: 75.0,
      goal: 'Lose weight',
      fitnessLevel: 'Beginner',
    );

    test('should recommend weight loss plan for weight loss goal', () {
      final plan = PlanRecommendationEngine.generateRecommendation(mockProfile, 5.0);
      expect(plan.type, PlanType.weightLoss);
      expect(plan.name, contains('Weight Loss'));
    });

    test('should recommend beginner plan for low weekly distance', () {
      final beginnerProfile = mockProfile.copyWith(goal: 'General fitness', fitnessLevel: 'Beginner');
      final plan = PlanRecommendationEngine.generateRecommendation(beginnerProfile, 5.0);
      expect(plan.type, PlanType.beginner);
    });

    test('should recommend 5k plan for intermediate with moderate distance', () {
      final intermediateProfile = mockProfile.copyWith(goal: 'Improve speed', fitnessLevel: 'Intermediate');
      final plan = PlanRecommendationEngine.generateRecommendation(intermediateProfile, 15.0);
      expect(plan.type, PlanType.fiveK);
    });

    test('should generate schedule for the correct number of weeks', () {
      final plan = PlanRecommendationEngine.generateRecommendation(mockProfile, 5.0);
      expect(plan.schedule.length, plan.totalWeeks * 7);
    });
  });

  group('PlanProgressTracker Tests', () {
    test('should calculate 100% adherence for future plans', () {
      final startDate = DateTime.now().add(const Duration(days: 1));
      final plan = TrainingPlan(
        id: '1',
        name: 'Test Plan',
        description: 'Desc',
        type: PlanType.beginner,
        totalWeeks: 1,
        startDate: startDate,
        schedule: [],
      );
      final adherence = PlanProgressTracker.calculateAdherence(plan);
      expect(adherence['score'], 100.0);
    });

    test('should calculate adherence based on completed sessions', () {
      final startDate = DateTime.now().subtract(const Duration(days: 2)); // Started 2 days ago (Day 1)
      // Day 1: 2 days ago
      // Day 2: 1 day ago
      // Day 3: today
      
      final plan = TrainingPlan(
        id: '1',
        name: 'Test Plan',
        description: 'Desc',
        type: PlanType.beginner,
        totalWeeks: 1,
        startDate: startDate,
        schedule: [
          TrainingSession(id: '1', week: 1, day: 1, title: 'S1', description: '', type: SessionType.easy, targetDurationMinutes: 30, isCompleted: true),
          TrainingSession(id: '2', week: 1, day: 2, title: 'S2', description: '', type: SessionType.easy, targetDurationMinutes: 30, isCompleted: false),
          TrainingSession(id: '3', week: 1, day: 3, title: 'S3', description: '', type: SessionType.easy, targetDurationMinutes: 30, isCompleted: false),
          TrainingSession(id: '4', week: 1, day: 4, title: 'S4', description: '', type: SessionType.easy, targetDurationMinutes: 30, isCompleted: false),
        ],
      );
      
      final adherence = PlanProgressTracker.calculateAdherence(plan);
      // Expected: 3 sessions should have been considered (Day 1, 2, 3), 1 is actually completed.
      expect(adherence['score'], closeTo(33.33, 0.1));
      expect(adherence['completed'], 1);
      expect(adherence['expected'], 3);
      expect(adherence['missed'], 1); // Only Day 2 is missed. Day 3 is today.
    });
  });
}
