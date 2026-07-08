import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/features/beat/ghost_target_provider.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';

class BeatLegendsPage extends ConsumerStatefulWidget {
  final String? id;
  const BeatLegendsPage({super.key, this.id});

  @override
  ConsumerState<BeatLegendsPage> createState() => _BeatLegendsPageState();
}

class _BeatLegendsPageState extends ConsumerState<BeatLegendsPage> {
  late GhostPace _selected;
  DifficultyTier _tier = DifficultyTier.goat;

  @override
  void initState() {
    super.initState();
    _selected = widget.id != null ? ghostPaceForId(widget.id!) : ghostPaces.first;
  }

  GhostPace get _active => _selected.forTier(_tier);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(L10n.tr('beat_the_legends', locale)), centerTitle: false),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ghostPaces.length,
                    separatorBuilder: (_, index) => const SizedBox(width: AppTheme.s12),
                    itemBuilder: (_, i) {
                      final g = ghostPaces[i];
                      final active = g.id == _selected.id;
                      final accent = legendAccent(g.legend);
                      return GestureDetector(
                        onTap: () => setState(() => _selected = g),
                        child: Container(
                          width: 84,
                          decoration: BoxDecoration(
                            color: active ? accent.withValues(alpha: 0.2) : cs.surface,
                            borderRadius: BorderRadius.circular(AppTheme.r16),
                            border: active ? Border.all(color: accent, width: 2) : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(g.legend.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: AppTheme.s4),
                              Text(g.legend.name.split(' ').first,
                                  style: text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                  const SizedBox(height: AppTheme.s16),
                  _TierSelector(tier: _tier, onChanged: (t) => setState(() => _tier = t)),
                  const SizedBox(height: AppTheme.s20),
                ]),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GhostHeader(g: _active),
                const SizedBox(height: AppTheme.s16),
                Container(
                  padding: const EdgeInsets.all(AppTheme.s16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppTheme.r16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(L10n.tr('pace_per_segment', locale), style: text.titleMedium),
                      Text(L10n.tr('seconds_per_km', locale),
                          style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
                      const SizedBox(height: AppTheme.s12),
                      SizedBox(height: 160, child: _SplitsChart(g: _active)),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.s16),
                Text(_active.description, style: text.bodyLarge!.copyWith(height: 1.6)),
                const SizedBox(height: AppTheme.s20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref.read(ghostTargetProvider.notifier).set(_active);
                      context.go('/run');
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(L10n.tr('race_this_ghost', locale)),
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.brand),
                  ),
                ),
                const SizedBox(height: AppTheme.s12),
                Text(
                  '${L10n.tr('during_a_run', locale)}${formatDuration(_active.totalSeconds)}.',
                  style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.55)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.s32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostHeader extends StatelessWidget {
  final GhostPace g;
  const _GhostHeader({required this.g});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = legendAccent(g.legend);
    return Container(
      padding: const EdgeInsets.all(AppTheme.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.9), accent.withValues(alpha: 0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.r24),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.white.withValues(alpha: 0.2), child: Text(g.legend.emoji, style: const TextStyle(fontSize: 30))),
          const SizedBox(width: AppTheme.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.name, style: text.titleLarge!.copyWith(color: Colors.white)),
                const SizedBox(height: AppTheme.s4),
                Text('${g.distanceLabel} · target ${formatDuration(g.totalSeconds)}',
                    style: text.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: 0.92))),
                const SizedBox(height: AppTheme.s2),
                Text('Avg ${formatPace(g.avgPaceMinPerKm)} /km',
                    style: text.labelMedium!.copyWith(color: Colors.white.withValues(alpha: 0.92))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierSelector extends StatelessWidget {
  final DifficultyTier tier;
  final ValueChanged<DifficultyTier> onChanged;
  const _TierSelector({required this.tier, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4, vertical: AppTheme.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.r12),
      ),
      child: Row(
        children: [
          for (final t in DifficultyTier.values) ...[
            if (t != DifficultyTier.values.first)
              const SizedBox(width: AppTheme.s4),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.s10),
                  decoration: BoxDecoration(
                    color: t == tier ? t.color.withValues(alpha: 0.22) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.r8),
                    border: t == tier ? Border.all(color: t.color) : null,
                  ),
                  child: Column(
                    children: [
                      Text(t.badge, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: AppTheme.s2),
                      Text(t.label,
                          style: text.labelSmall!.copyWith(
                            color: t == tier ? t.color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: t == tier ? FontWeight.w700 : FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SplitsChart extends StatelessWidget {
  final GhostPace g;
  const _SplitsChart({required this.g});

  @override
  Widget build(BuildContext context) {
    final accent = legendAccent(g.legend);
    final max = g.splits.reduce((a, b) => a > b ? a : b);
    final min = g.splits.reduce((a, b) => a < b ? a : b);
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [for (int i = 0; i < g.splits.length; i++) FlSpot(i.toDouble(), g.splits[i])],
            color: accent,
            dotData: FlDotData(show: false),
            isCurved: true,
            curveSmoothness: 0.3,
            belowBarData: BarAreaData(show: true, color: accent.withValues(alpha: 0.14)),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text('${v.toInt() + 1}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
              interval: (g.splits.length / 6).ceilToDouble().clamp(1, 999),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text('${v.toInt()}s',
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Colors.white10)),
        borderData: FlBorderData(show: false),
        minY: min * 0.95,
        maxY: max * 1.05,
      ),
    );
  }
}
