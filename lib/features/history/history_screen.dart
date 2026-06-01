import 'package:flutter/material.dart';

import '../../models/run_session.dart';
import '../../services/run_storage_service.dart';
import '../../widgets/history_card.dart';
import '../../widgets/animations/shimmer_loading.dart';

import '../../core/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RunSession> runs = [];
  List<dynamic> flattenedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRuns();
  }

  Future<void> loadRuns() async {
    final loadedRuns = await RunStorageService.getRuns();
    
    // Group runs by month/year
    Map<String, List<RunSession>> groups = {};
    for (var run in loadedRuns) {
      final parts = run.date.split('/');
      if (parts.length == 3) {
        String monthYear = '${_getMonthName(parts[1])} ${parts[2]}';
        if (!groups.containsKey(monthYear)) {
          groups[monthYear] = [];
        }
        groups[monthYear]!.add(run);
      } else {
        if (!groups.containsKey('RECENT')) groups['RECENT'] = [];
        groups['RECENT']!.add(run);
      }
    }

    final List<dynamic> flattened = [];
    groups.forEach((key, runs) {
      flattened.add(key); // Header
      flattened.addAll(runs); // Runs
    });

    if (!mounted) return;

    setState(() {
      runs = loadedRuns;
      flattenedItems = flattened;
      isLoading = false;
    });
  }

  String _getMonthName(String monthString) {
    int month = int.tryParse(monthString) ?? 1;
    const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    return months[(month - 1).clamp(0, 11)];
  }

  Widget _buildSkeletonHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ShimmerLoading(
            isLoading: true,
            child: const SkeletonBox(height: 120, borderRadius: 24),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('HISTORY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
      body: isLoading
          ? _buildSkeletonHistory()
          : runs.isEmpty
              ? const Center(
                  child: Text(
                    'No runs yet',
                    style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: flattenedItems.length,
                  itemBuilder: (context, index) {
                    final item = flattenedItems[index];
                    
                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                        child: Text(
                          item.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      );
                    }
                    
                    final session = item as RunSession;
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 5 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: HistoryCard(
                        session: session,
                      ),
                    );
                  },
                ),
    );
  }
}

