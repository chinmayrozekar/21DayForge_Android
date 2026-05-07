import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import 'dart:convert';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Profile section
          _buildSectionHeader(context, 'Profile'),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: settings.profileImageData != null
                  ? _decodeProfileImage(settings.profileImageData!)
                  : null,
              child: settings.profileImageData == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              settings.userName.isEmpty ? 'Your Name' : settings.userName,
            ),
            subtitle: Text(
              settings.userName.isEmpty ? 'Tap to set your name' : 'Tap to edit',
            ),
            onTap: _editName,
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Change Photo'),
            onTap: _changePhoto,
          ),
          const Divider(),

          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: Icon(_getAppearanceIcon(settings.appearance)),
            title: const Text('Theme'),
            subtitle: Text(settings.appearance.label),
            onTap: _showThemePicker,
          ),
          const Divider(),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Daily Reminder'),
            value: settings.reminderEnabled,
            onChanged: _toggleReminder,
          ),
          if (settings.reminderEnabled)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Remind at'),
              subtitle: Text(_formatTime(
                settings.reminderHour,
                settings.reminderMinute,
              )),
              onTap: _showTimePicker,
            ),
          const Divider(),

          // Feedback section
          _buildSectionHeader(context, 'Feedback'),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Send Feedback'),
            subtitle: const Text('Found a bug or have a suggestion?'),
            onTap: _sendFeedback,
          ),
          const Divider(),

          // About section
          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Developer'),
            subtitle: Text('Chinmay Rozekar'),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.timer),
            title: Text('Days to form a habit'),
            subtitle: Text('21'),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Proudly Made in 🇮🇳 भारत',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  ImageProvider? _decodeProfileImage(String data) {
    try {
      return MemoryImage(base64Decode(data));
    } catch (_) {
      return null;
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  IconData _getAppearanceIcon(AppAppearance appearance) {
    switch (appearance) {
      case AppAppearance.system:
        return Icons.brightness_auto;
      case AppAppearance.light:
        return Icons.light_mode;
      case AppAppearance.dark:
        return Icons.dark_mode;
    }
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  void _editName() {
    final controller = TextEditingController(
      text: ref.read(settingsProvider).userName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Your name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(settingsProvider.notifier).setUserName(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      ref.read(settingsProvider.notifier).setProfileImageData(base64String);
    }
  }

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppAppearance.values.map((appearance) {
            return RadioListTile<AppAppearance>(
              title: Text(appearance.label),
              secondary: Icon(appearance.icon),
              value: appearance,
              groupValue: ref.read(settingsProvider).appearance,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setAppearance(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _toggleReminder(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService.requestAuthorization();
      if (granted) {
        final settings = ref.read(settingsProvider);
        await NotificationService.scheduleDailyReminder(
          hour: settings.reminderHour,
          minute: settings.reminderMinute,
        );
        ref.read(settingsProvider.notifier).setReminderEnabled(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder scheduled successfully'),
            ),
          );
        }
      } else {
        ref.read(settingsProvider.notifier).setReminderEnabled(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable notifications and alarm permissions in Settings'),
            ),
          );
        }
      }
    } else {
      await NotificationService.cancelDailyReminder();
      ref.read(settingsProvider.notifier).setReminderEnabled(false);
    }
  }

  Future<void> _showTimePicker() async {
    final settings = ref.read(settingsProvider);
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
    );
    if (time != null) {
      ref.read(settingsProvider.notifier).setReminderTime(
            time.hour,
            time.minute,
          );
      if (settings.reminderEnabled) {
        await NotificationService.scheduleDailyReminder(
          hour: time.hour,
          minute: time.minute,
        );
      }
    }
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback email: chinmay.rozekar@gmail.com'),
      ),
    );
  }
}