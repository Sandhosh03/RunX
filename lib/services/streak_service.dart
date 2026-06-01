import '../models/run_session.dart';
import '../models/streak_data.dart';

class StreakService {
  static StreakData _calculate(List<RunSession> runs) {
    if (runs.isEmpty) {
      return StreakData(
        currentStreak: 0,
        longestStreak: 0,
      );
    }

    // Extract unique dates as YYYY-MM-DD strings for faster comparison
    final Set<String> uniqueDates = {};
    for (var run in runs) {
      final parts = run.date.split('/');
      if (parts.length == 3) {
        // Normalize to YYYY-MM-DD
        final normalized = "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
        uniqueDates.add(normalized);
      }
    }

    final List<DateTime> sortedDates = uniqueDates
        .map((d) => DateTime.parse(d))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return StreakData(currentStreak: 0, longestStreak: 0);
    }

    int currentStreak = 1;
    int longestStreak = 1;

    // Check if the most recent run was today or yesterday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastRun = sortedDates.first;
    final diffFromToday = today.difference(lastRun).inDays;

    if (diffFromToday > 1) {
      // Streak broken
      return StreakData(currentStreak: 0, longestStreak: 0); // Need to calculate longest from history though
    }

    for (int i = 0; i < sortedDates.length - 1; i++) {
      final difference = sortedDates[i].difference(sortedDates[i + 1]).inDays;

      if (difference == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (difference > 1) {
        // Sequence broken, but keep tracking longest
        currentStreak = 1;
      }
    }

    // If streak is not active (last run was not today/yesterday), current is 0
    final activeStreak = diffFromToday <= 1 ? currentStreak : 0;

    return StreakData(
      currentStreak: activeStreak,
      longestStreak: longestStreak,
    );
  }

  static StreakData calculateStreak(List<RunSession> runs) {
    // If we have a lot of runs, offload calculation
    if (runs.length > 50) {
      // Note: This needs to be handled async in the UI if used with compute
      // For now, we optimize the synchronous path as it's small data usually
      return _calculate(runs);
    }
    return _calculate(runs);
  }
}