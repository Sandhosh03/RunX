import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class CommunityService {
  static final SupabaseClient _client = SupabaseService.client;

  static Future<List<Community>> getTrendingCommunities() async {
    try {
      final List<dynamic> response = await _client
          .from('communities')
          .select('*, community_members(user_id)')
          .limit(10);
      
      final userId = AuthService.userId;
      
      return response.map((data) {
        final List<dynamic> members = data['community_members'] ?? [];
        final bool isJoined = userId != null && members.any((m) => m['user_id'] == userId);
        
        return Community(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          members: data['members_count'] ?? 0,
          category: data['category'] ?? 'General',
          image: data['image'] ?? '🏙️',
          isJoined: isJoined,
        );
      }).toList();
    } catch (e) {
      return []; // Return empty if failed/no data
    }
  }

  static Future<List<CommunityRun>> getUpcomingRuns() async {
    try {
      final List<dynamic> response = await _client
          .from('group_runs')
          .select()
          .order('date', ascending: true)
          .limit(5);
      
      return response.map((data) {
        return CommunityRun(
          id: data['id'],
          title: data['title'],
          date: data['date'],
          time: data['time'],
          location: data['location'],
          participants: data['participants_count'] ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> joinCommunity(String communityId) async {
    final userId = AuthService.userId;
    if (userId == null) return;

    try {
      await _client.from('community_members').insert({
        'community_id': communityId,
        'user_id': userId,
      });
    } catch (e) {
      // Handle error
    }
  }
}
