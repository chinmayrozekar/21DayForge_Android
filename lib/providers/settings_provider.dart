import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

enum AppAppearance {
  system,
  light,
  dark;

  String get label {
    switch (this) {
      case AppAppearance.system:
        return 'System';
      case AppAppearance.light:
        return 'Light';
      case AppAppearance.dark:
        return 'Dark';
    }
  }

  IconData get icon {
    switch (this) {
      case AppAppearance.system:
        return Icons.brightness_auto;
      case AppAppearance.light:
        return Icons.light_mode;
      case AppAppearance.dark:
        return Icons.dark_mode;
    }
  }

  ColorScheme? get colorScheme {
    switch (this) {
      case AppAppearance.system:
        return null;
      case AppAppearance.light:
        return ColorScheme.light();
      case AppAppearance.dark:
        return ColorScheme.dark();
    }
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = SettingsState(
      userName: StorageService.userName,
      hasCompletedOnboarding: StorageService.hasCompletedOnboarding,
      appearance: AppAppearance.values.firstWhere(
        (a) => a.name == StorageService.appearance,
        orElse: () => AppAppearance.system,
      ),
      profileImageData: StorageService.profileImageData,
      reminderEnabled: StorageService.reminderEnabled,
      reminderHour: StorageService.reminderHour,
      reminderMinute: StorageService.reminderMinute,
    );
  }

  void setUserName(String name) {
    StorageService.userName = name;
    state = state.copyWith(userName: name);
  }

  void setHasCompletedOnboarding(bool value) {
    StorageService.hasCompletedOnboarding = value;
    state = state.copyWith(hasCompletedOnboarding: value);
  }

  void setAppearance(AppAppearance appearance) {
    StorageService.appearance = appearance.name;
    state = state.copyWith(appearance: appearance);
  }

  void setProfileImageData(String? data) {
    StorageService.profileImageData = data;
    state = state.copyWith(profileImageData: data);
  }

  void setReminderEnabled(bool enabled) {
    StorageService.reminderEnabled = enabled;
    state = state.copyWith(reminderEnabled: enabled);
  }

  void setReminderTime(int hour, int minute) {
    StorageService.reminderHour = hour;
    StorageService.reminderMinute = minute;
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
  }
}

class SettingsState {
  final String userName;
  final bool hasCompletedOnboarding;
  final AppAppearance appearance;
  final String? profileImageData;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  const SettingsState({
    this.userName = '',
    this.hasCompletedOnboarding = false,
    this.appearance = AppAppearance.system,
    this.profileImageData,
    this.reminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
  });

  SettingsState copyWith({
    String? userName,
    bool? hasCompletedOnboarding,
    AppAppearance? appearance,
    String? profileImageData,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      appearance: appearance ?? this.appearance,
      profileImageData: profileImageData ?? this.profileImageData,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});