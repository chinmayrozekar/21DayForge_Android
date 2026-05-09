import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'views/home_view.dart';
import 'views/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  try {
    await NotificationService.init();
  } catch (_) {
    // Notification init failure must not prevent app launch
  }
  runApp(const ProviderScope(child: DayforgeApp()));
}

class DayforgeApp extends ConsumerWidget {
  const DayforgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final lightTheme = ref.watch(themeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    final theme = getTheme(settings.appearance, lightTheme, darkTheme, context);

    return MaterialApp(
      title: '21DayForge',
      theme: theme,
      home: settings.hasCompletedOnboarding
          ? const HomeView()
          : const OnboardingView(),
      debugShowCheckedModeBanner: false,
    );
  }
}