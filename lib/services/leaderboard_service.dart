import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

enum LeaderboardCategory { xp, distance, calories }

class LeaderboardEntry {
  final String userId;
  final String name;
  final double value;
  final int rank;
  final int level;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.value,
    required this.rank,
    required this.level,
  });
}

class LeaderboardService {
  static final SupabaseClient _client = SupabaseService.client;

  static Stream<List<LeaderboardEntry>> getRealtimeLeaderboard(LeaderboardCategory category) {
    String column = '';
    switch (category) {
      case LeaderboardCategory.xp: column = 'xp'; break;
      case LeaderboardCategory.distance: column = 'total_distance'; break;
      case LeaderboardCategory.calories: column = 'total_calories'; break;
    }

    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order(column, ascending: false)
        .limit(20)
        .map((data) {
          int rank = 1;
          return data.map((json) {
            return LeaderboardEntry(
              userId: json['id'],
              name: json['full_name'] ?? 'Runner',
              value: (json[column] as num?)?.toDouble() ?? 0.0,
              rank: rank++,
              level: json['level'] ?? 1,
            );
          }).toList();
        });
  }
}
