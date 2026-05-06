import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge.dart';
import '../widgets/heatmap_view.dart';
import '../widgets/stat_card.dart';

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesProvider);
    final activeChallenges =
        challenges.where((c) => c.status == ChallengeStatus.active).toList();
    final completedChallenges =
        challenges.where((c) => c.status == ChallengeStatus.completed).toList();

    final completionDates = _getCompletionDates(challenges);
    final currentStreak = _calculateCurrentStreak(completionDates);
    final longestStreak = _calculateLongestStreak(completionDates);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        centerTitle: true,
      ),
      body: challenges.isEmpty
          ? _buildEmptyState(context)
          : _buildContent(
              context,
              ref,
              currentStreak: currentStreak,
              longestStreak: longestStreak,
              activeCount: activeChallenges.length,
              completedCount: completedChallenges.length,
              challenges: challenges,
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Challenges Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a 21-day challenge to see your stats here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required int currentStreak,
    required int longestStreak,
    required int activeCount,
    required int completedCount,
    required List<Challenge> challenges,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              title: 'Current Streak',
              value: '$currentStreak',
              unit: currentStreak == 1 ? 'day' : 'days',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            StatCard(
              title: 'Longest Streak',
              value: '$longestStreak',
              unit: longestStreak == 1 ? 'day' : 'days',
              icon: Icons.emoji_events,
              color: Colors.amber,
            ),
            StatCard(
              title: 'Active',
              value: '$activeCount',
              unit: activeCount == 1 ? 'challenge' : 'challenges',
              icon: Icons.directions_run,
              color: Colors.blue,
            ),
            StatCard(
              title: 'Completed',
              value: '$completedCount',
              unit: completedCount == 1 ? 'challenge' : 'challenges',
              icon: Icons.verified,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Heatmap
        HeatmapView(challenges: challenges),
        const SizedBox(height: 24),

        // Challenge breakdown
        Text(
          'Challenges',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...challenges.map((challenge) => _buildChallengeItem(context, ref, challenge)),
      ],
    );
  }

  Widget _buildChallengeItem(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          challenge.isTodayCompleted ? Icons.check_circle : Icons.circle_outlined,
          color:
              challenge.isTodayCompleted ? Colors.green : Theme.of(context).colorScheme.outline,
        ),
        title: Text(challenge.title),
        subtitle: Text('${challenge.completedDays}/21 days'),
        trailing: Text(
          '${(challenge.progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    challenge.isComplete ? Colors.green : null,
              ),
        ),
        onTap: challenge.isTodayActionable
            ? () {
                challenge.toggleToday();
                ref.read(challengesProvider.notifier).refresh();
              }
            : null,
      ),
    );
  }

  Set<DateTime> _getCompletionDates(List<Challenge> challenges) {
    final dates = <DateTime>{};
    for (final challenge in challenges) {
      for (var i = 0; i < challenge.dailyStatus.length; i++) {
        if (challenge.dailyStatus[i]) {
          final date = challenge.startDate.add(Duration(days: i));
          dates.add(DateTime(date.year, date.month, date.day));
        }
      }
    }
    return dates;
  }

  int _calculateCurrentStreak(Set<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = dates.toList()..sort();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    var checkDate = dates.contains(todayDate) ? todayDate : yesterdayDate;
    if (!dates.contains(checkDate)) return 0;

    var streak = 0;
    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateLongestStreak(Set<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = dates.toList()..sort();
    var longest = 1;
    var current = 1;

    for (var i = 1; i < sortedDates.length; i++) {
      final daysBetween =
          sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (daysBetween == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }

    return longest;
  }
}