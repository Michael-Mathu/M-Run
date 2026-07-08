import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/data/sample_activities.dart';
import 'package:mwendo_app/widgets/route_map.dart';

class ActivityDetailPage extends ConsumerWidget {
  final String id;
  const ActivityDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(activityByIdProvider(id)).value;
    final a = run?.toSampleActivity() ?? SampleActivity.forId(id);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => SharePlus.instance.share(ShareParams(
              text: 'I just completed a ${a.type} — '
                  '${formatDistance(a.distanceM)} in ${formatDuration(a.durationMs)} '
                  'via Mwendo!',
            )),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: RouteMap(points: a.route),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(a.type, style: text.headlineLarge),
                const SizedBox(height: AppTheme.s4),
                Text(
                  '${a.startedAt.day}/${a.startedAt.month}/${a.startedAt.year}',
                  style: text.bodyMedium!
                      .copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: AppTheme.s20),
                _StatsGrid(a: a, locale: locale),
                const SizedBox(height: AppTheme.s28),
                _ChartCard(
                  title: L10n.tr('elevation', locale),
                  unit: 'm',
                  values: a.elevation,
                  color: AppTheme.brand,
                ),
                const SizedBox(height: AppTheme.s16),
                _ChartCard(
                  title: L10n.tr('pace', locale),
                  unit: '/km',
                  values: a.pace,
                  color: Colors.blueAccent,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final SampleActivity a;
  final AppLocale locale;
  const _StatsGrid({required this.a, required this.locale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      _Stat(formatDistance(a.distanceM), L10n.tr('distance', locale)),
      _Stat(formatPace(a.avgPaceMinPerKm), L10n.tr('avg_pace', locale)),
      _Stat(formatDuration(a.durationMs), L10n.tr('time', locale)),
      _Stat(a.calories.toString(), L10n.tr('calories', locale)),
      _Stat(a.elevationGainM.toStringAsFixed(0), L10n.tr('elev_gain', locale)),
      _Stat(a.avgHeartRate.toString(), L10n.tr('avg_hr', locale)),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.s12,
      crossAxisSpacing: AppTheme.s12,
      childAspectRatio: 1.6,
      children: items
          .map((s) => Container(
                padding: const EdgeInsets.all(AppTheme.s12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppTheme.r12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.value,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ])),
                    const SizedBox(height: AppTheme.s4),
                    Text(s.label.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(
                                color: cs.onSurface.withValues(alpha: 0.55))),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _Stat {
  final String value;
  final String label;
  const _Stat(this.value, this.label);
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final List<double> values;
  final Color color;

  const _ChartCard({
    required this.title,
    required this.unit,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          Text('$min–$max $unit',
              style: text.bodySmall!
                  .copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: AppTheme.s12),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < values.length; i++)
                        FlSpot(i.toDouble(), values[i]),
                    ],
                    color: color,
                    dotData: FlDotData(show: false),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.14),
                    ),
                  ),
                ],
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                minY: min,
                maxY: max,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
