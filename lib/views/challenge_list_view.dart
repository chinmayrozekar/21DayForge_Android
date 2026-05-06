import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge.dart';
import 'challenge_detail_view.dart';
import 'new_challenge_view.dart';

class ChallengeListView extends ConsumerWidget {
  const ChallengeListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('21DayForge'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNewChallenge(context),
          ),
        ],
      ),
      body: challenges.isEmpty
          ? _buildEmptyState(context)
          : _buildList(context, ref, challenges),
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
              'Start Your Journey',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first 21-day challenge.',
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

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Challenge> challenges,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Dismissible(
          key: Key(challenge.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) => _confirmDelete(context, challenge),
          onDismissed: (direction) {
            ref.read(challengesProvider.notifier).deleteChallenge(challenge);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: _buildStatusIcon(context, challenge),
              title: Text(challenge.title),
              subtitle: _buildSubtitle(context, challenge),
              trailing: Text(
                '${challenge.completedDays}/21',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              onTap: () => _navigateToDetail(context, challenge),
              onLongPress: () => _showEditDialog(context, ref, challenge),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(BuildContext context, Challenge challenge) {
    IconData icon;
    Color color;

    switch (challenge.status) {
      case ChallengeStatus.upcoming:
        icon = Icons.schedule;
        color = Colors.blue;
        break;
      case ChallengeStatus.active:
        icon = challenge.isTodayCompleted
            ? Icons.check_circle
            : Icons.local_fire_department;
        color = challenge.isTodayCompleted ? Colors.green : Colors.orange;
        break;
      case ChallengeStatus.completed:
        icon = Icons.verified;
        color = Colors.green;
        break;
      case ChallengeStatus.expired:
        icon = Icons.warning;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color);
  }

  Widget _buildSubtitle(BuildContext context, Challenge challenge) {
    String text;
    switch (challenge.status) {
      case ChallengeStatus.upcoming:
        text = 'Starts ${_formatDate(challenge.startDate)}';
        break;
      case ChallengeStatus.active:
        text = 'Day ${challenge.currentDay} of 21';
        break;
      case ChallengeStatus.completed:
        text = 'Completed!';
        break;
      case ChallengeStatus.expired:
        text = '${challenge.completedDays}/21 - Expired';
        break;
    }

    return Text(text);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  void _showNewChallenge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const NewChallengeView(),
    );
  }

  void _navigateToDetail(BuildContext context, Challenge challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailView(challenge: challenge),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Challenge challenge) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Challenge'),
            content: Text(
              'This will permanently delete "${challenge.title}" and all ${challenge.completedDays} days of progress.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Challenge challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NewChallengeView(challenge: challenge),
    );
  }
}