import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class FeedItem {
  final String id;
  final String userId;
  final String userName;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int likesCount;
  final bool isLikedByMe;

  FeedItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.likesCount,
    required this.isLikedByMe,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json, String? currentUserId) {
    final List<dynamic> likes = json['feed_likes'] ?? [];
    return FeedItem(
      id: json['id'],
      userId: json['user_id'],
      userName: json['profiles']['full_name'] ?? 'Runner',
      type: json['type'],
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      likesCount: likes.length,
      isLikedByMe: currentUserId != null && likes.any((l) => l['user_id'] == currentUserId),
    );
  }
}

class FeedService {
  static final SupabaseClient _client = SupabaseService.client;

  static Stream<List<FeedItem>> getFeedStream() {
    final userId = AuthService.userId;
    return _client
        .from('activity_feed')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .limit(20)
        .asyncMap((data) async {
          // Enrich with profile names and likes
          final List<dynamic> enriched = await _client
              .from('activity_feed')
              .select('*, profiles(full_name), feed_likes(user_id)')
              .order('timestamp', ascending: false)
              .limit(20);
          
          return enriched.map((json) => FeedItem.fromJson(json, userId)).toList();
        });
  }

  static Future<void> postActivity({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final userId = AuthService.userId;
    if (userId == null) return;

    try {
      await _client.from('activity_feed').insert({
        'user_id': userId,
        'type': type,
        'data': data,
      });
    } catch (e) {
      // Fail silently
    }
  }

  static Future<void> toggleLike(String feedItemId, bool currentlyLiked) async {
    final userId = AuthService.userId;
    if (userId == null) return;

    try {
      if (currentlyLiked) {
        await _client.from('feed_likes').delete().match({
          'feed_item_id': feedItemId,
          'user_id': userId,
        });
      } else {
        await _client.from('feed_likes').insert({
          'feed_item_id': feedItemId,
          'user_id': userId,
        });
      }
    } catch (e) {
      // Handle error
    }
  }
}
