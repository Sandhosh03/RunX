import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class SocialUser {
  final String id;
  final String name;
  final int level;
  final double totalDistance;
  final bool isFollowing;

  SocialUser({
    required this.id,
    required this.name,
    required this.level,
    required this.totalDistance,
    required this.isFollowing,
  });
}

class SocialService {
  static final SupabaseClient _client = SupabaseService.client;

  static Future<List<SocialUser>> searchUsers(String query) async {
    final currentUserId = AuthService.userId;
    if (currentUserId == null) return [];

    try {
      final List<dynamic> response = await _client
          .from('profiles')
          .select('*, follows!following_id(follower_id)')
          .ilike('full_name', '%$query%')
          .neq('id', currentUserId)
          .limit(10);
      
      return response.map((data) {
        final List<dynamic> follows = data['follows'] ?? [];
        final bool isFollowing = follows.any((f) => f['follower_id'] == currentUserId);
        
        return SocialUser(
          id: data['id'],
          name: data['full_name'] ?? 'Runner',
          level: data['level'] ?? 1,
          totalDistance: (data['total_distance'] as num?)?.toDouble() ?? 0.0,
          isFollowing: isFollowing,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> toggleFollow(String targetUserId, bool currentlyFollowing) async {
    final currentUserId = AuthService.userId;
    if (currentUserId == null) return;

    try {
      if (currentlyFollowing) {
        await _client.from('follows').delete().match({
          'follower_id': currentUserId,
          'following_id': targetUserId,
        });
      } else {
        await _client.from('follows').insert({
          'follower_id': currentUserId,
          'following_id': targetUserId,
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  static Future<Map<String, int>> getSocialStats() async {
    final userId = AuthService.userId;
    if (userId == null) return {'followers': 0, 'following': 0};

    try {
      final followers = await _client.from('follows').select().eq('following_id', userId);
      final following = await _client.from('follows').select().eq('follower_id', userId);
      
      return {
        'followers': followers.length,
        'following': following.length,
      };
    } catch (e) {
      return {'followers': 0, 'following': 0};
    }
  }
}
