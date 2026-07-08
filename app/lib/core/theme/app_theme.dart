import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mwendo design system.
/// Opinionated, athletic, high-contrast — built to hold a candle to Strava / NRC.
class AppTheme {
  // ---- Brand palette (curated, not algorithmic) ----
  static const Color brand = Color(0xFFFF5A1F); // kinetic orange
  static const Color brandSoft = Color(0xFFFF8A5C);
  static const Color recording = Color(0xFFFE2E4B); // live red pulse
  static const Color paused = Color(0xFFF5A623);
  static const Color idle = Color(0xFF8A8A8E);
  static const Color sos = Color(0xFFFF1744);
  static const Color achievement = Color(0xFFFFD15C); // gold

  // Dark surfaces
  static const Color darkScaffold = Color(0xFF0B0B0C);
  static const Color darkCard = Color(0xFF161618);
  static const Color darkElevated = Color(0xFF1F1F22);

  // Light surfaces
  static const Color lightScaffold = Color(0xFFF7F7F4);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF0EFEA);

  // Spacing scale (4pt grid)
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s48 = 48;

  // Radius scale
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r24 = 24;
  static const double rFull = 999;

  // Motion
  static const Duration dFast = Duration(milliseconds: 150);
  static const Duration dMed = Duration(milliseconds: 300);
  static const Duration dSlow = Duration(milliseconds: 520);
  static const Curve curveSnappy = Curves.easeOutCubic;
  static const Curve curveSpring = Curves.elasticOut;

  // Heart-rate zone ramp (1..5): gray -> blue -> green -> orange -> red
  static const List<Color> hrZones = [
    Color(0xFF9AA0A6),
    Color(0xFF4A90E2),
    Color(0xFF2BB673),
    Color(0xFFFFA726),
    Color(0xFFFE2E4B),
  ];

  // Challenge tiers
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFC0C6CC);
  static const Color tierGold = Color(0xFFFFD15C);
  static const Color tierPlatinum = Color(0xFF7FE7E0);

  static LinearGradient get brandGradient => const LinearGradient(
        colors: [brand, Color(0xFFFF8A3D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static TextTheme _text(bool dark) {
    final base = GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, letterSpacing: -1.5),
        displayMedium: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1),
        headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.4),
        labelSmall: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4),
      ),
    );
    return base.apply(
      bodyColor: dark ? Colors.white : const Color(0xFF1A1A1C),
      displayColor: dark ? Colors.white : const Color(0xFF1A1A1C),
    );
  }

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightScaffold,
    colorScheme: ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.light)
        .copyWith(
      primary: brand,
      onPrimary: Colors.white,
      secondary: achievement,
      onSecondary: Colors.black,
      surface: lightCard,
      onSurface: const Color(0xFF1A1A1C),
      surfaceContainerHighest: lightElevated,
      error: sos,
      onError: Colors.white,
      primaryContainer: brandSoft.withValues(alpha: 0.18),
    ),
    textTheme: _text(false),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
      margin: EdgeInsets.zero,
    ),
    iconTheme: const IconThemeData(size: 24, fill: 1, weight: 600),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: s24, vertical: s16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightScaffold,
      indicatorColor: brand.withValues(alpha: 0.16),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightElevated,
      contentTextStyle: const TextStyle(color: Color(0xFF1A1A1C)),
      actionTextColor: brand,
    ),
    dialogTheme: DialogThemeData(backgroundColor: lightCard),
    extensions: [AppExtensions.light],
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkScaffold,
    colorScheme: ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.dark)
        .copyWith(
      primary: brand,
      onPrimary: Colors.white,
      secondary: achievement,
      onSecondary: Colors.black,
      surface: darkCard,
      onSurface: Colors.white,
      surfaceContainerHighest: darkElevated,
      error: sos,
      onError: Colors.white,
      primaryContainer: brandSoft.withValues(alpha: 0.20),
    ),
    textTheme: _text(true),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
      margin: EdgeInsets.zero,
    ),
    iconTheme: const IconThemeData(size: 24, fill: 1, weight: 600),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: s24, vertical: s16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkScaffold,
      indicatorColor: brand.withValues(alpha: 0.18),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkElevated,
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: brandSoft,
    ),
    dialogTheme: DialogThemeData(backgroundColor: darkElevated),
    extensions: [AppExtensions.dark],
  );
}

/// App-specific semantic tokens passed through the theme tree.
class AppExtensions extends ThemeExtension<AppExtensions> {
  final Color recording;
  final Color paused;
  final Color idle;
  final Color sos;
  final Color achievement;
  final List<Color> hrZones;
  final LinearGradient brandGradient;

  const AppExtensions({
    required this.recording,
    required this.paused,
    required this.idle,
    required this.sos,
    required this.achievement,
    required this.hrZones,
    required this.brandGradient,
  });

  static const light = AppExtensions(
    recording: AppTheme.recording,
    paused: AppTheme.paused,
    idle: AppTheme.idle,
    sos: AppTheme.sos,
    achievement: AppTheme.achievement,
    hrZones: AppTheme.hrZones,
    brandGradient: LinearGradient(colors: [AppTheme.brand, Color(0xFFFF8A3D)]),
  );

  static const dark = AppExtensions(
    recording: AppTheme.recording,
    paused: AppTheme.paused,
    idle: AppTheme.idle,
    sos: AppTheme.sos,
    achievement: AppTheme.achievement,
    hrZones: AppTheme.hrZones,
    brandGradient: LinearGradient(colors: [AppTheme.brand, Color(0xFFFF8A3D)]),
  );

  @override
  AppExtensions copyWith({
    Color? recording,
    Color? paused,
    Color? idle,
    Color? sos,
    Color? achievement,
    List<Color>? hrZones,
    LinearGradient? brandGradient,
  }) =>
      AppExtensions(
        recording: recording ?? this.recording,
        paused: paused ?? this.paused,
        idle: idle ?? this.idle,
        sos: sos ?? this.sos,
        achievement: achievement ?? this.achievement,
        hrZones: hrZones ?? this.hrZones,
        brandGradient: brandGradient ?? this.brandGradient,
      );

  @override
  AppExtensions lerp(ThemeExtension<AppExtensions>? other, double t) {
    if (other is! AppExtensions) return this;
    return AppExtensions(
      recording: Color.lerp(recording, other.recording, t)!,
      paused: Color.lerp(paused, other.paused, t)!,
      idle: Color.lerp(idle, other.idle, t)!,
      sos: Color.lerp(sos, other.sos, t)!,
      achievement: Color.lerp(achievement, other.achievement, t)!,
      hrZones: hrZones,
      brandGradient: brandGradient,
    );
  }
}

extension AppContext on BuildContext {
  AppExtensions get tokens => Theme.of(this).extension<AppExtensions>()!;
}
