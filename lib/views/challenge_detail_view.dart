import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';
import '../providers/challenge_provider.dart';
import '../widgets/day_circle.dart';
import 'new_challenge_view.dart';

class ChallengeDetailView extends ConsumerWidget {
  final Challenge challenge;

  const ChallengeDetailView({super.key, required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch so the UI rebuilds whenever a day is toggled or a freeze is used.
    ref.watch(challengesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEdit(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          _buildStatusBanner(context),
          const SizedBox(height: 24),

          // Progress circle
          _buildProgressSection(context),
          const SizedBox(height: 24),

          // 21-day grid
          _buildDayGrid(context, ref),
          const SizedBox(height: 24),

          // Today's action
          _buildTodayAction(context, ref),
          const SizedBox(height: 24),

          // Details
          _buildDetailsSection(context),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    switch (challenge.status) {
      case ChallengeStatus.upcoming:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Starts ${_formatDate(challenge.startDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      case ChallengeStatus.expired:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'This challenge ended ${_formatDate(challenge.endDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      case ChallengeStatus.active:
      case ChallengeStatus.completed:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProgressSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: challenge.progress,
                    strokeWidth: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    color: _getProgressColor(context),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${challenge.completedDays}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'of 21',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (challenge.goal.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              challenge.goal,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(BuildContext context) {
    switch (challenge.status) {
      case ChallengeStatus.completed:
        return Colors.green;
      case ChallengeStatus.expired:
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildDayGrid(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 21,
      itemBuilder: (context, index) {
        final canTap = _canToggleDay(index);
        final isCompleted = challenge.dailyStatus[index];
        final isCurrent = challenge.status == ChallengeStatus.active &&
            index + 1 == challenge.currentDay;
        final isFuture = challenge.status == ChallengeStatus.active &&
            index + 1 > challenge.currentDay;

        return DayCircle(
          dayNumber: index + 1,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isFuture: isFuture,
          isDisabled: !canTap,
          onTap: canTap
              ? () {
                  challenge.toggleDay(index);
                  ref.read(challengesProvider.notifier).refresh();
                }
              : null,
        );
      },
    );
  }

  bool _canToggleDay(int index) {
    switch (challenge.status) {
      case ChallengeStatus.upcoming:
        return false;
      case ChallengeStatus.active:
        return index < challenge.currentDay;
      case ChallengeStatus.completed:
      case ChallengeStatus.expired:
        return true;
    }
  }

  Widget _buildTodayAction(BuildContext context, WidgetRef ref) {
    switch (challenge.status) {
      case ChallengeStatus.upcoming:
        return Card(
          child: ListTile(
            leading: const Icon(Icons.hourglass_empty),
            title: const Text("Challenge hasn't started yet"),
          ),
        );
      case ChallengeStatus.active:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (challenge.canUseFreeze)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton.icon(
                  onPressed: () {
                    challenge.useFreeze();
                    ref.read(challengesProvider.notifier).refresh();
                  },
                  icon: const Icon(Icons.ac_unit),
                  label: Text('Freeze (${challenge.availableFreezeDays})'),
                ),
              ),
            FilledButton.icon(
              onPressed: () {
                final index = challenge.currentDay - 1;
                challenge.toggleDay(index);
                ref.read(challengesProvider.notifier).refresh();
              },
              icon: Icon(
                challenge.isTodayCompleted
                    ? Icons.undo
                    : Icons.check,
              ),
              label: Text(
                challenge.isTodayCompleted
                    ? 'Undo Today'
                    : 'Complete Day ${challenge.currentDay}',
              ),
            ),
          ],
        );
      case ChallengeStatus.completed:
        return Card(
          color: Colors.green.withOpacity(0.1),
          child: ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.green),
            title: const Text(
              'Challenge Complete!',
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
      case ChallengeStatus.expired:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Started', _formatDate(challenge.startDate)),
            _buildDetailRow('Ends', _formatDate(challenge.endDate)),
            _buildDetailRow(
              'Current Streak',
              '${challenge.currentStreak} days',
              showFlame: challenge.currentStreak >= 3,
            ),
            _buildDetailRow('Best Streak', '${challenge.longestStreak} days'),
            _buildDetailRow('Completion', '${(challenge.progress * 100).toInt()}%'),
            if (challenge.status == ChallengeStatus.active)
              _buildDetailRow('Days Remaining', '${challenge.daysRemaining}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showFlame = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              if (showFlame) ...[
                const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
              ],
              Text(value),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NewChallengeView(challenge: challenge),
    );
  }
}