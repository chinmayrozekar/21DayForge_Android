import 'package:flutter/material.dart';
import '../models/challenge.dart';

class HeatmapView extends StatelessWidget {
  final List<Challenge> challenges;

  const HeatmapView({super.key, required this.challenges});

  @override
  Widget build(BuildContext context) {
    final completionMap = _buildCompletionMap();
    final weeks = _buildWeeks();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            // Heatmap
            SizedBox(
              height: 120,
              child: Row(
                children: [
                  // Day labels
                  Column(
                    children: [
                      const SizedBox(height: 2),
                      _buildDayLabel(''),
                      _buildDayLabel('Mon'),
                      const SizedBox(height: 2),
                      _buildDayLabel('Wed'),
                      const SizedBox(height: 2),
                      _buildDayLabel('Fri'),
                      const SizedBox(height: 2),
                      _buildDayLabel(''),
                    ],
                  ),
                  const SizedBox(width: 4),
                  // Grid
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: weeks.map((week) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Column(
                              children: week.map((date) {
                                final count = completionMap[date] ?? 0;
                                final isFuture = date.isAfter(DateTime.now());
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: _cellColor(count, isFuture, context),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Less',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(width: 4),
                for (var i = 0; i < 5; i++)
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: _legendColor(i, context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                const SizedBox(width: 4),
                Text(
                  'More',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayLabel(String label) {
    return SizedBox(
      height: 14,
      child: Text(
        label,
        style: const TextStyle(fontSize: 9),
      ),
    );
  }

  Map<DateTime, int> _buildCompletionMap() {
    final map = <DateTime, int>{};
    for (final challenge in challenges) {
      for (var i = 0; i < challenge.dailyStatus.length; i++) {
        if (challenge.dailyStatus[i]) {
          final date = challenge.startDate.add(Duration(days: i));
          final normalized = DateTime(date.year, date.month, date.day);
          map[normalized] = (map[normalized] ?? 0) + 1;
        }
      }
    }
    return map;
  }

  List<List<DateTime>> _buildWeeks() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final weekday = today.weekday;
    final daysToSubtract = weekday - 1;
    
    final currentWeekStart = todayDate.subtract(Duration(days: daysToSubtract));
    final weeks = <List<DateTime>>[];
    
    for (var weekOffset = 15; weekOffset >= 0; weekOffset--) {
      final weekStart = currentWeekStart.subtract(Duration(days: weekOffset * 7));
      final week = <DateTime>[];
      for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
        week.add(weekStart.add(Duration(days: dayOffset)));
      }
      weeks.add(week);
    }
    
    return weeks;
  }

  Color _cellColor(int count, bool isFuture, BuildContext context) {
    if (isFuture) {
      return Theme.of(context).colorScheme.outline.withOpacity(0.08);
    }
    switch (count) {
      case 0:
        return Theme.of(context).colorScheme.outline.withOpacity(0.12);
      case 1:
        return Colors.green.withOpacity(0.35);
      case 2:
        return Colors.green.withOpacity(0.55);
      case 3:
        return Colors.green.withOpacity(0.75);
      default:
        return Colors.green.withOpacity(0.95);
    }
  }

  Color _legendColor(int level, BuildContext context) {
    switch (level) {
      case 0:
        return Theme.of(context).colorScheme.outline.withOpacity(0.12);
      case 1:
        return Colors.green.withOpacity(0.35);
      case 2:
        return Colors.green.withOpacity(0.55);
      case 3:
        return Colors.green.withOpacity(0.75);
      default:
        return Colors.green.withOpacity(0.95);
    }
  }
}