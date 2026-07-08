import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class MetricTile extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Color? accent;
  final bool hero;

  const MetricTile({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.accent,
    this.hero = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isPlaceholder = value == '--' || value == '--:--';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            style: (hero ? text.displayMedium! : text.headlineMedium!).copyWith(
              fontWeight: FontWeight.w800,
              color: accent ?? cs.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            children: [
              TextSpan(text: value),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: hero ? 18 : 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.s4),
        Text(
          label.toUpperCase(),
          style: text.labelSmall!.copyWith(
            color: isPlaceholder ? cs.onSurface.withValues(alpha: 0.3) : cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
