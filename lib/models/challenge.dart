import 'package:hive/hive.dart';

part 'challenge.g.dart';

enum ChallengeStatus {
  upcoming,
  active,
  completed,
  expired;

  String get label {
    switch (this) {
      case ChallengeStatus.upcoming:
        return 'Upcoming';
      case ChallengeStatus.active:
        return 'Active';
      case ChallengeStatus.completed:
        return 'Completed';
      case ChallengeStatus.expired:
        return 'Expired';
    }
  }

  String get icon {
    switch (this) {
      case ChallengeStatus.upcoming:
        return 'clock';
      case ChallengeStatus.active:
        return 'flame_fill';
      case ChallengeStatus.completed:
        return 'checkmark_seal_fill';
      case ChallengeStatus.expired:
        return 'warning';
    }
  }
}

@HiveType(typeId: 0)
class Challenge extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String goal;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  List<bool> dailyStatus;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  List<bool>? freezeDays;

  Challenge({
    required this.id,
    required this.title,
    this.goal = '',
    DateTime? startDate,
    List<bool>? dailyStatus,
    List<bool>? freezeDays,
    DateTime? createdAt,
  })  : startDate = startDate ?? DateTime.now(),
        dailyStatus = dailyStatus ?? List.filled(21, false),
        freezeDays = freezeDays ?? List.filled(21, false),
        createdAt = createdAt ?? DateTime.now();

  DateTime get endDate => startDate.add(const Duration(days: 20));

  int get elapsedDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return today.difference(start).inDays;
  }

  ChallengeStatus get status {
    if (isComplete) return ChallengeStatus.completed;
    if (elapsedDays < 0) return ChallengeStatus.upcoming;
    if (elapsedDays >= 21) return ChallengeStatus.expired;
    return ChallengeStatus.active;
  }

  int get currentDay {
    final elapsed = elapsedDays;
    if (elapsed < 0) return 0;
    return (elapsed + 1).clamp(1, 21);
  }

  int get daysRemaining {
    if (status == ChallengeStatus.expired || status == ChallengeStatus.completed) return 0;
    final remaining = 21 - elapsedDays;
    return remaining.clamp(0, 21);
  }

  bool get isComplete => dailyStatus.every((day) => day);

  int get completedDays => dailyStatus.where((day) => day).length;

  double get progress => completedDays / 21.0;

  bool get isTodayActionable => status == ChallengeStatus.active;

  bool get isTodayCompleted {
    if (status != ChallengeStatus.active && status != ChallengeStatus.completed) {
      return false;
    }
    final index = elapsedDays;
    if (index < 0 || index >= 21) return false;
    return dailyStatus[index];
  }

  int get currentStreak {
    final end = (elapsedDays + 1).clamp(0, 21);
    if (end <= 0) return 0;
    int streak = 0;
    for (int i = end - 1; i >= 0; i--) {
      final frozen = freezeDays != null && freezeDays![i];
      if (frozen) continue;
      if (dailyStatus[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    int longest = 0;
    int current = 0;
    for (final completed in dailyStatus) {
      if (completed) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }
    return longest;
  }

  static const int maxFreezeDays = 3;

  int get availableFreezeDays {
    if (freezeDays == null) return 0;
    final used = freezeDays!.where((day) => day).length;
    return (maxFreezeDays - used).clamp(0, maxFreezeDays);
  }

  bool get isTodayFrozen {
    if (status != ChallengeStatus.active) return false;
    if (freezeDays == null) return false;
    final index = elapsedDays;
    if (index < 0 || index >= 21) return false;
    return freezeDays![index];
  }

  bool get canUseFreeze {
    return status == ChallengeStatus.active &&
        availableFreezeDays > 0 &&
        !isTodayCompleted &&
        !isTodayFrozen;
  }

  void toggleDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= 21) return;
    if (status == ChallengeStatus.upcoming) return;
    if (status == ChallengeStatus.active && dayIndex >= currentDay) return;
    dailyStatus[dayIndex] = !dailyStatus[dayIndex];
    save();
  }

  void toggleToday() {
    if (status != ChallengeStatus.active) return;
    final index = currentDay - 1;
    if (index < 0 || index >= 21) return;
    dailyStatus[index] = !dailyStatus[index];
    save();
  }

  void markTodayComplete() {
    if (status != ChallengeStatus.active) return;
    final index = currentDay - 1;
    if (index < 0 || index >= 21) return;
    dailyStatus[index] = true;
    save();
  }

  void useFreeze() {
    if (status != ChallengeStatus.active) return;
    if (availableFreezeDays <= 0) return;
    if (freezeDays == null) return;
    final index = elapsedDays;
    if (index < 0 || index >= 21) return;
    if (dailyStatus[index] || freezeDays![index]) return;
    freezeDays![index] = true;
    save();
  }
}