import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/leaderboard_service.dart';
import '../../widgets/animations/fade_slide_animation.dart';
import '../../widgets/level_badge.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardCategory _currentCategory = LeaderboardCategory.xp;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        switch (_tabController.index) {
          case 0: _currentCategory = LeaderboardCategory.xp; break;
          case 1: _currentCategory = LeaderboardCategory.distance; break;
          case 2: _currentCategory = LeaderboardCategory.calories; break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Leaderboards', style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white54,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'XP'),
            Tab(text: 'Distance'),
            Tab(text: 'Calories'),
          ],
        ),
      ),
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: LeaderboardService.getRealtimeLeaderboard(_currentCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rankings available yet.', style: TextStyle(color: Colors.white24)));
          }

          final runners = snapshot.data!;
          return Column(
            children: [
              if (runners.length >= 3) _buildPodium(runners.take(3).toList()),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: runners.length > 3 ? runners.length - 3 : 0,
                    itemBuilder: (context, index) {
                      final runner = runners[index + 3];
                      return FadeSlideAnimation(
                        delay: Duration(milliseconds: index * 50),
                        child: _buildRunnerTile(runner),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumSpot(topThree[1], 100, Colors.white60), // 2nd
          _buildPodiumSpot(topThree[0], 130, AppColors.primary), // 1st
          _buildPodiumSpot(topThree[2], 80, Colors.white30), // 3rd
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(LeaderboardEntry runner, double height, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.surface,
              child: Text(runner.name[0], style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 24)),
            ),
            LevelBadge(level: runner.level, size: 24),
          ],
        ),
        const SizedBox(height: 12),
        Text(runner.name.split(' ')[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(_formatValue(runner.value), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.outline),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              '#${runner.rank}',
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRunnerTile(LeaderboardEntry runner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 35,
            child: Text(
              '#${runner.rank}',
              style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(width: 5),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            child: Text(runner.name[0], style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(runner.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                Text('LEVEL ${runner.level}', style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
          Text(
            _formatValue(runner.value),
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatValue(double val) {
    if (_currentCategory == LeaderboardCategory.xp) return '${val.toInt()} XP';
    if (_currentCategory == LeaderboardCategory.distance) return '${val.toStringAsFixed(1)} KM';
    return '${val.toInt()} KCAL';
  }
}
