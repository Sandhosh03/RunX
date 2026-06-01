import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/feed_service.dart';
import '../../services/social_service.dart';
import '../../widgets/animations/fade_slide_animation.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<SocialUser> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await SocialService.searchUsers(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Community', style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white54,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Activity Feed'),
            Tab(text: 'Explore People'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityFeed(),
          _buildExplorePeople(),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return StreamBuilder<List<FeedItem>>(
      stream: FeedService.getFeedStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No activity yet. Start running!', style: TextStyle(color: Colors.white24)),
          );
        }

        final feed = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: feed.length,
          itemBuilder: (context, index) {
            final item = feed[index];
            return FadeSlideAnimation(
              delay: Duration(milliseconds: index * 100),
              child: _buildFeedCard(item),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedCard(FeedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _formatTimestamp(item.timestamp),
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildTypeBadge(item.type),
            ],
          ),
          const SizedBox(height: 20),
          _buildActivityContent(item),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          Row(
            children: [
              IconButton(
                onPressed: () => FeedService.toggleLike(item.id, item.isLikedByMe),
                icon: Icon(
                  item.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                  color: item.isLikedByMe ? AppColors.primary : Colors.white54,
                  size: 20,
                ),
              ),
              Text('${item.likesCount}', style: const TextStyle(color: Colors.white54)),
              const SizedBox(width: 20),
              const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54, size: 20),
              const SizedBox(width: 8),
              const Text('0', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContent(FeedItem item) {
    switch (item.type) {
      case 'run':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed a ${item.data['distance']} KM run!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSmallStat(Icons.timer_outlined, '${item.data['duration']} min'),
                const SizedBox(width: 15),
                _buildSmallStat(Icons.bolt, '${item.data['calories']} kcal'),
              ],
            ),
          ],
        );
      case 'achievement':
        return Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                'Unlocked: ${item.data['title']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      default:
        return Text(item.type.toUpperCase());
    }
  }

  Widget _buildSmallStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }

  Widget _buildExplorePeople() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _searchController,
            onChanged: _handleSearch,
            decoration: InputDecoration(
              hintText: 'Search runners...',
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
            ),
          ),
        ),
        if (_isSearching)
          const LinearProgressIndicator(backgroundColor: Colors.transparent, color: AppColors.primary),
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(child: Text('Search for friends and rival runners', style: TextStyle(color: Colors.white24)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return _buildUserTile(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserTile(SocialUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(user.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 2),
                Text('Level ${user.level} • ${user.totalDistance.toStringAsFixed(1)} KM',
                    style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () async {
                await SocialService.toggleFollow(user.id, user.isFollowing);
                _handleSearch(_searchController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isFollowing ? Colors.transparent : AppColors.primary,
                foregroundColor: user.isFollowing ? Colors.white : Colors.black,
                elevation: 0,
                side: user.isFollowing ? const BorderSide(color: AppColors.outline) : BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(user.isFollowing ? 'FOLLOWING' : 'FOLLOW', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}';
  }
}
