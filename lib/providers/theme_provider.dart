import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

final themeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(settingsProvider);
  
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepOrange,
    brightness: Brightness.light,
  );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
  );
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepOrange,
    brightness: Brightness.dark,
  );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
  );
});

ThemeData getTheme(AppAppearance appearance, ThemeData lightTheme, ThemeData darkTheme) {
  switch (appearance) {
    case AppAppearance.light:
      return lightTheme;
    case AppAppearance.dark:
      return darkTheme;
    case AppAppearance.system:
      return lightTheme;
  }
}