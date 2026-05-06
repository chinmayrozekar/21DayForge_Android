import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';

class StorageService {
  static const String _challengesBoxName = 'challenges';
  static const String _settingsBoxName = 'settings';

  static late Box<Challenge> _challengesBox;
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChallengeAdapter());
    _challengesBox = await Hive.openBox<Challenge>(_challengesBoxName);
    _prefs = await SharedPreferences.getInstance();
  }

  // Challenge operations
  static Box<Challenge> get challengesBox => _challengesBox;

  static List<Challenge> getAllChallenges() {
    return _challengesBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> addChallenge(Challenge challenge) async {
    await _challengesBox.put(challenge.id, challenge);
  }

  static Future<void> updateChallenge(Challenge challenge) async {
    await challenge.save();
  }

  static Future<void> deleteChallenge(Challenge challenge) async {
    await _challengesBox.delete(challenge.id);
  }

  static Challenge? getChallenge(String id) {
    return _challengesBox.get(id);
  }

  // Settings operations
  static String get userName => _prefs.getString('userName') ?? '';
  static set userName(String value) => _prefs.setString('userName', value);

  static bool get hasCompletedOnboarding => _prefs.getBool('hasCompletedOnboarding') ?? false;
  static set hasCompletedOnboarding(bool value) => _prefs.setBool('hasCompletedOnboarding', value);

  static String get appearance => _prefs.getString('appearance') ?? 'system';
  static set appearance(String value) => _prefs.setString('appearance', value);

  static String? get profileImageData => _prefs.getString('profileImageData');
  static set profileImageData(String? value) {
    if (value != null) {
      _prefs.setString('profileImageData', value);
    } else {
      _prefs.remove('profileImageData');
    }
  }

  static bool get reminderEnabled => _prefs.getBool('reminderEnabled') ?? false;
  static set reminderEnabled(bool value) => _prefs.setBool('reminderEnabled', value);

  static int get reminderHour => _prefs.getInt('reminderHour') ?? 9;
  static set reminderHour(int value) => _prefs.setInt('reminderHour', value);

  static int get reminderMinute => _prefs.getInt('reminderMinute') ?? 0;
  static set reminderMinute(int value) => _prefs.setInt('reminderMinute', value);
}