import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/challenge_provider.dart';
import '../providers/settings_provider.dart';
import '../models/shloka.dart';
import '../widgets/daily_shloka_card.dart';
import '../widgets/today_challenge_card.dart';

class TodayView extends ConsumerWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final activeChallenges = ref.watch(activeChallengesProvider);
    final completedToday = ref.watch(completedTodayProvider);
    final pendingToday = ref.watch(pendingTodayProvider);
    final allDoneToday = ref.watch(allDoneTodayProvider);

    final greeting = settings.userName.isEmpty
        ? 'Today'
        : 'Hi, ${settings.userName}';
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final dailyShloka = getDailyShloka();

    return Scaffold(
      body: SafeArea(
        child: activeChallenges.isEmpty
            ? _buildEmptyState(context)
            : _buildContent(
                context,
                ref,
                greeting: greeting,
                dateStr: dateStr,
                dailyShloka: dailyShloka,
                completedToday: completedToday,
                pendingToday: pendingToday,
                allDoneToday: allDoneToday,
              ),
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
              Icons.local_fire_department,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Challenges',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a 21-day challenge to see your daily tasks here.',
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
    required String greeting,
    required String dateStr,
    required Shloka dailyShloka,
    required List completedToday,
    required List pendingToday,
    required bool allDoneToday,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Pending section
        if (pendingToday.isNotEmpty) ...[
          _buildSectionHeader(context, 'Pending'),
          const SizedBox(height: 12),
          ...pendingToday.map((challenge) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TodayChallengeCard(challenge: challenge),
              )),
          const SizedBox(height: 16),
        ],

        // Celebration banner
        if (allDoneToday) ...[
          _buildCelebrationBanner(context),
          const SizedBox(height: 16),
        ],

        // Completed section
        if (completedToday.isNotEmpty) ...[
          _buildSectionHeader(context, 'Done'),
          const SizedBox(height: 12),
          ...completedToday.map((challenge) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TodayChallengeCard(challenge: challenge),
              )),
          const SizedBox(height: 16),
        ],

        // Summary bar
        if (activeChallenges(ref).isNotEmpty)
          _buildSummaryBar(
            context,
            doneCount: completedToday.length,
            pendingCount: pendingToday.length,
          ),

        // Daily Shloka
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: DailyShlokaCard(shloka: dailyShloka),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  List activeChallenges(WidgetRef ref) {
    return ref.watch(activeChallengesProvider);
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _buildCelebrationBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star,
            size: 40,
            color: Colors.amber,
          ),
          const SizedBox(height: 8),
          Text(
            'All done for today!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "You're building great habits. See you tomorrow.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(
    BuildContext context, {
    required int doneCount,
    required int pendingCount,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                '$doneCount done',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
              ),
            ],
          ),
          const Spacer(),
          if (pendingCount > 0)
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '$pendingCount remaining',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}