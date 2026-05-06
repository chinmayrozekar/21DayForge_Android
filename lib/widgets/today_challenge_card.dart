import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';
import '../providers/challenge_provider.dart';

class TodayChallengeCard extends ConsumerWidget {
  final Challenge challenge;

  const TodayChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: challenge.isTodayActionable
            ? () {
                challenge.toggleToday();
                ref.read(challengesProvider.notifier).refresh();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Icon(
                challenge.isTodayCompleted
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                size: 28,
                color: challenge.isTodayCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: challenge.isTodayCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: challenge.isTodayCompleted
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Day ${challenge.currentDay} of 21',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (challenge.currentStreak > 1) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: Colors.orange,
                              ),
                              Text(
                                '${challenge.currentStreak}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Progress circle
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: challenge.progress,
                      strokeWidth: 3,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      '${(challenge.progress * 100).toInt()}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}