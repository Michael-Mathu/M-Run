import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted app appearance (dark by default, matching the brand).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode_v1';

  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.dark;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        state = ThemeMode.values.firstWhere(
          (m) => m.name == raw,
          orElse: () => ThemeMode.dark,
        );
      }
    } catch (_) {}
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {}
  }

  Future<void> cycle() async {
    final order = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
    final next = order[(order.indexOf(state) + 1) % order.length];
    await set(next);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
