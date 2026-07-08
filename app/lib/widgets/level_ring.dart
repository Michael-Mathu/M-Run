import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Circular level indicator with the level number in the middle.
class LevelRing extends StatelessWidget {
  final int level;
  final double progress; // 0..1
  final double size;
  final Color color;

  const LevelRing({
    super.key,
    required this.level,
    required this.progress,
    this.size = 64,
    this.color = AppTheme.brand,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('LV',
                  style: text.labelSmall!.copyWith(
                      color: Colors.white70, letterSpacing: 1)),
              Text(level.toString(),
                  style: text.titleLarge!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horizontal XP bar toward the next level.
class XpBar extends StatelessWidget {
  final int xpIntoLevel;
  final int xpForNextLevel;
  final double progress;
  final Color color;

  const XpBar({
    super.key,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.progress,
    this.color = AppTheme.brand,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.rFull),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: AppTheme.s6),
        Text(
          '$xpIntoLevel / $xpForNextLevel XP',
          style: text.labelSmall!.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
