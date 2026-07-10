import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mwendo design system.
/// Opinionated, athletic, high-contrast — built to hold a candle to Strava / NRC.
class AppTheme {
  // ---- Brand palette (curated, not algorithmic) ----
  static const Color brand = Color(0xFFFF5A1F); // kinetic orange
  static const Color brandSoft = Color(0xFFFF8A5C);
  // Flag-refined reds: deeper, more "Kenyan" than the old neon alert reds.
  static const Color recording = Color(0xFFC5283D); // live red pulse
  static const Color sos = Color(0xFFC5283D); // SOS / danger
  static const Color paused = Color(0xFFF5A623);
  static const Color idle = Color(0xFF8A8A8E);
  static const Color achievement = Color(0xFFFFD15C); // gold
  static const Color warning = Color(0xFFF5A623); // amber warning

  // Kenyan-flag semantic accents ("K-Earth"): green = prosperity/terrain/
  // success/data-viz. Not literal flag stripes — mapped to UI roles only.
  static const Color flagGreen = Color(0xFF1B8A5A); // dark-theme green
  static const Color flagGreenLight = Color(0xFF0E5C36); // light-theme green (deeper for contrast)
  static const Color flagRed = Color(0xFFC5283D); // flag's deeper red

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
  static const double s14 = 14;
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

  // Elevation / shadow tokens
  static const List<BoxShadow> elevation0 = [];
  static const List<BoxShadow> elevation1 = [
    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> elevation2 = [
    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> elevation3 = [
    BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> elevation4 = [
    BoxShadow(color: Colors.black38, blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Icon container sizes
  static const double iconContainerSm = 40;
  static const double iconContainerMd = 48;
  static const double iconContainerLg = 56;
  static const double iconContainerXl = 64;

  // Avatar sizes
  static const double avatarXs = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
  static const double avatarXl = 68;

  // Navigation bar height
  static const double navBarHeight = 72;

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
  /// Kenyan-flag green (theme-aware): terrain/success/data-viz accent.
  final Color flagGreen;
  /// Large numeric metric value style (one ramp across all screens).
  final TextStyle metricValue;
  /// Secondary metric label style (uppercase baked in; no call-site toUpper).
  final TextStyle metricLabel;

  const AppExtensions({
    required this.recording,
    required this.paused,
    required this.idle,
    required this.sos,
    required this.achievement,
    required this.hrZones,
    required this.brandGradient,
    required this.flagGreen,
    required this.metricValue,
    required this.metricLabel,
  });

  static const _metricValue = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.0,
  );
  static const _metricLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppTheme.idle,
  );

  static const light = AppExtensions(
    recording: AppTheme.recording,
    paused: AppTheme.paused,
    idle: AppTheme.idle,
    sos: AppTheme.sos,
    achievement: AppTheme.achievement,
    hrZones: AppTheme.hrZones,
    brandGradient: LinearGradient(colors: [AppTheme.brand, Color(0xFFFF8A3D)]),
    flagGreen: AppTheme.flagGreenLight,
    metricValue: _metricValue,
    metricLabel: _metricLabel,
  );

  static const dark = AppExtensions(
    recording: AppTheme.recording,
    paused: AppTheme.paused,
    idle: AppTheme.idle,
    sos: AppTheme.sos,
    achievement: AppTheme.achievement,
    hrZones: AppTheme.hrZones,
    brandGradient: LinearGradient(colors: [AppTheme.brand, Color(0xFFFF8A3D)]),
    flagGreen: AppTheme.flagGreen,
    metricValue: _metricValue,
    metricLabel: _metricLabel,
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
    Color? flagGreen,
    TextStyle? metricValue,
    TextStyle? metricLabel,
  }) =>
      AppExtensions(
        recording: recording ?? this.recording,
        paused: paused ?? this.paused,
        idle: idle ?? this.idle,
        sos: sos ?? this.sos,
        achievement: achievement ?? this.achievement,
        hrZones: hrZones ?? this.hrZones,
        brandGradient: brandGradient ?? this.brandGradient,
        flagGreen: flagGreen ?? this.flagGreen,
        metricValue: metricValue ?? this.metricValue,
        metricLabel: metricLabel ?? this.metricLabel,
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
      flagGreen: Color.lerp(flagGreen, other.flagGreen, t)!,
      metricValue: TextStyle.lerp(metricValue, other.metricValue, t)!,
      metricLabel: TextStyle.lerp(metricLabel, other.metricLabel, t)!,
    );
  }
}

extension AppContext on BuildContext {
  AppExtensions get tokens => Theme.of(this).extension<AppExtensions>()!;
  /// Shorthand alias for [tokens] (theme-aware colors in widgets).
  AppExtensions get cs => tokens;
}

/// Motion vocabulary — use these tokens instead of hardcoded durations.
///   dFast (150ms) — micro-interactions, ticks
///   dMed  (300ms) — state changes, content fades
///   dSlow (520ms) — entrance/staggered reveals
///   curveSnappy — UI state changes (easeOutCubic)
///   curveSpring — playful/overshoot (trophy pop, first-run hint)
///
/// Haptic intent map:
///   selection — passive UI nav (tab switch)
///   light     — affirmative confirmation
///   medium    — state-changing action (start run)
///   heavy     — destructive/significant (stop run)
///   celebrate — level-up / achievement
// ponytail: motion/haptic doc kept as comments to avoid an unused-symbol lint.
