import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';
import '../services/storage_service.dart';

// Challenge list provider
final challengesProvider = StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  return ChallengesNotifier();
});

class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier() : super([]) {
    _loadChallenges();
  }

  void _loadChallenges() {
    state = StorageService.getAllChallenges();
  }

  Future<void> addChallenge(Challenge challenge) async {
    await StorageService.addChallenge(challenge);
    _loadChallenges();
  }

  Future<void> updateChallenge(Challenge challenge) async {
    await StorageService.updateChallenge(challenge);
    _loadChallenges();
  }

  Future<void> deleteChallenge(Challenge challenge) async {
    await StorageService.deleteChallenge(challenge);
    _loadChallenges();
  }

  void refresh() {
    _loadChallenges();
  }
}

// Active challenges provider
final activeChallengesProvider = Provider<List<Challenge>>((ref) {
  final challenges = ref.watch(challengesProvider);
  return challenges.where((c) => c.status == ChallengeStatus.active).toList();
});

// Completed today provider
final completedTodayProvider = Provider<List<Challenge>>((ref) {
  final challenges = ref.watch(activeChallengesProvider);
  return challenges.where((c) => c.isTodayCompleted).toList();
});

// Pending today provider
final pendingTodayProvider = Provider<List<Challenge>>((ref) {
  final challenges = ref.watch(activeChallengesProvider);
  return challenges.where((c) => !c.isTodayCompleted).toList();
});

// All done today provider
final allDoneTodayProvider = Provider<bool>((ref) {
  final active = ref.watch(activeChallengesProvider);
  final pending = ref.watch(pendingTodayProvider);
  return active.isNotEmpty && pending.isEmpty;
});