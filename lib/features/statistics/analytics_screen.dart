import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/run_session.dart';
import '../../services/run_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/animations/fade_slide_animation.dart';
import '../../widgets/premium/premium_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<RunSession> allRuns = [];
  List<RunSession> recentRuns = [];
  bool isLoading = true;
  
  // Stats from old LeaderboardScreen
  double totalDistance = 0;
  double totalCalories = 0;
  double longestRun = 0;
  double averageDistance = 0;
  
  // View states
  bool showPaceLineChart = false;
  int selectedChartView = 0; // 0: Performance (Line), 1: Trends (Bar)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedRuns = await RunStorageService.getRuns();
    
    double distance = 0;
    double calories = 0;
    double longest = 0;

    for (var run in loadedRuns) {
      distance += run.distance;
      calories += run.calories;
      if (run.distance > longest) longest = run.distance;
    }

    setState(() {
      allRuns = loadedRuns;
      recentRuns = loadedRuns.take(7).toList().reversed.toList();
      totalDistance = distance;
      totalCalories = calories;
      longestRun = longest;
      averageDistance = loadedRuns.isEmpty ? 0 : distance / loadedRuns.length;
      isLoading = false;
    });
  }

  List<FlSpot> _generateDistanceData() {
    return List.generate(allRuns.length, (i) => FlSpot(i.toDouble(), allRuns[i].distance));
  }

  List<FlSpot> _generatePaceData() {
    return List.generate(
      allRuns.length,
      (i) => FlSpot(i.toDouble(), allRuns[i].averagePace ?? 0),
    );
  }

  double get _maxDistance => recentRuns.isEmpty ? 1.0 : recentRuns.map((r) => r.distance).reduce((a, b) => a > b ? a : b);
  double get _maxPace => recentRuns.isEmpty ? 1.0 : recentRuns.map((r) => r.averagePace ?? 0.0).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : allRuns.isEmpty
              ? const Center(child: Text('Not enough data to generate analytics.', style: TextStyle(color: Colors.white54)))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: _buildViewToggle(),
                      ),
                      const SizedBox(height: 25),
                      
                      if (selectedChartView == 0) ...[
                        FadeSlideAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: _buildPerformanceChart(),
                        ),
                      ] else ...[
                        FadeSlideAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            children: [
                              _buildBarChart(
                                title: 'DISTANCE (KM)',
                                data: recentRuns.map((r) => r.distance).toList(),
                                labels: recentRuns.map((r) => r.date.split('/')[0]).toList(),
                                maxValue: _maxDistance,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 20),
                              _buildBarChart(
                                title: 'AVERAGE PACE (min/KM)',
                                data: recentRuns.map((r) => r.averagePace ?? 0.0).toList(),
                                labels: recentRuns.map((r) => r.date.split('/')[0]).toList(),
                                maxValue: _maxPace,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 30),
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.3,
                          children: [
                            _buildStatCard('TOTAL DISTANCE', '${totalDistance.toStringAsFixed(1)} KM', 0),
                            _buildStatCard('CALORIES', totalCalories.toStringAsFixed(0), 1),
                            _buildStatCard('LONGEST RUN', '${longestRun.toStringAsFixed(1)} KM', 2),
                            _buildStatCard('AVERAGE', '${averageDistance.toStringAsFixed(1)} KM', 3),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 400),
                        child: _buildConsistencyHeatmap(),
                      ),
                      
                      const SizedBox(height: 30),
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 500),
                        child: _buildInsightsSection(),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleViewItem('PERFORMANCE', selectedChartView == 0, () => setState(() => selectedChartView = 0)),
          ),
          Expanded(
            child: _toggleViewItem('TRENDS', selectedChartView == 1, () => setState(() => selectedChartView = 1)),
          ),
        ],
      ),
    );
  }

  Widget _toggleViewItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white38,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PERFORMANCE HISTORY',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
            ),
            _buildChartTypeToggle(),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outline),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: showPaceLineChart ? _generatePaceData() : _generateDistanceData(),
                  isCurved: true,
                  barWidth: 3,
                  color: AppColors.primary,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          _toggleTypeItem('DIST', !showPaceLineChart, () => setState(() => showPaceLineChart = false)),
          _toggleTypeItem('PACE', showPaceLineChart, () => setState(() => showPaceLineChart = true)),
        ],
      ),
    );
  }

  Widget _toggleTypeItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white38,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart({
    required String title,
    required List<double> data,
    required List<String> labels,
    required double maxValue,
    required Color color,
  }) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (index) {
                final heightFactor = maxValue > 0 ? (data[index] / maxValue).clamp(0.0, 1.0) : 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      data[index].toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: heightFactor),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Container(
                          width: 16,
                          height: 120 * value,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildConsistencyHeatmap() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_on_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text(
                'CONSISTENCY HEATMAP',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 25),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              bool isActive = index % 3 == 0 || index % 5 == 0;
              if (index > 20) isActive = true;

              return Container(
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withValues(alpha: 0.3 + (index % 3) * 0.2) : AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('LESS', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              _buildHeatmapLegend(AppColors.outline),
              const SizedBox(width: 2),
              _buildHeatmapLegend(AppColors.primary.withValues(alpha: 0.4)),
              const SizedBox(width: 2),
              _buildHeatmapLegend(AppColors.primary),
              const SizedBox(width: 5),
              const Text('MORE', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapLegend(Color color) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)));
  }

  Widget _buildInsightsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SMART INSIGHTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 25),
          _buildInsight(Icons.auto_graph_rounded, 'Your performance has improved by 12% this week.'),
          _buildInsight(Icons.speed_rounded, 'Maintaining a sub-6:00 pace helps burn 15% more calories.'),
          _buildInsight(Icons.emoji_events_rounded, 'You are in the top 5% of runners in your age group.'),
        ],
      ),
    );
  }

  Widget _buildInsight(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
