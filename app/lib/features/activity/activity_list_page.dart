import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/data/gpx_export.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/data/sample_activities.dart';
import 'package:mwendo_app/widgets/skeleton.dart';

enum _Sort { date, distance, duration }

class ActivityListPage extends ConsumerStatefulWidget {
  const ActivityListPage({super.key});

  @override
  ConsumerState<ActivityListPage> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends ConsumerState<ActivityListPage> {
  _Sort _sort = _Sort.date;
  String? _typeFilter;

  List<RunRecord> _apply(List<RunRecord> runs) {
    var list = runs;
    if (_typeFilter != null) {
      list = list.where((r) => r.type == _typeFilter).toList();
    }
    list = [...list];
    switch (_sort) {
      case _Sort.date:
        list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      case _Sort.distance:
        list.sort((a, b) => b.distanceM.compareTo(a.distanceM));
      case _Sort.duration:
        list.sort((a, b) => b.durationMs.compareTo(a.durationMs));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final runs = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(L10n.tr('activity', locale)), centerTitle: false),
      body: runs.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppTheme.s24),
          itemCount: 3,
          separatorBuilder: (_, index) => const SizedBox(height: AppTheme.s12),
          itemBuilder: (_, index) => const SkeletonCard(height: 88),
        ),
        error: (_, _) => _EmptyState(text: text, cs: cs, locale: locale),
        data: (real) {
          final items = real.isNotEmpty ? real : <RunRecord>[];
          if (items.isEmpty) return _EmptyState(text: text, cs: cs, locale: locale);
          final types = items.map((r) => r.type).toSet().toList()..sort();
          final sorted = _apply(items);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _Chip(
                                  label: L10n.tr('all', locale),
                                  active: _typeFilter == null,
                                  onTap: () => setState(() => _typeFilter = null),
                                ),
                                for (final t in types)
                                  _Chip(
                                    label: t,
                                    active: _typeFilter == t,
                                    onTap: () => setState(() => _typeFilter = t),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.s8),
                    Row(
                      children: [
                        Text(L10n.tr('sort', locale),
                            style: text.labelMedium!.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6))),
                        const SizedBox(width: AppTheme.s8),
                        DropdownButton<_Sort>(
                          value: _sort,
                          underline: const SizedBox.shrink(),
                          items: [
                            DropdownMenuItem(
                                value: _Sort.date,
                                child: Text(L10n.tr('sort_date', locale))),
                            DropdownMenuItem(
                                value: _Sort.distance,
                                child: Text(L10n.tr('sort_distance', locale))),
                            DropdownMenuItem(
                                value: _Sort.duration,
                                child: Text(L10n.tr('sort_duration', locale))),
                          ],
                          onChanged: (s) => setState(() => _sort = s!),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.file_download_outlined, size: 18),
                          label: Text(L10n.tr('export_json', locale)),
                          onPressed: () => _exportJson(context, ref, locale, sorted),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.s24),
                sliver: SliverList.separated(
                  separatorBuilder: (_, index) => const SizedBox(height: AppTheme.s12),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) => _ActivityTile(
                    a: sorted[i].toSampleActivity(),
                    onExportGpx: () => _exportGpx(context, ref, locale, sorted[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportJson(BuildContext context, WidgetRef ref, AppLocale locale,
      List<RunRecord> runs) async {
    final json = jsonFromRuns(runs);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'mwendo_activities.json'));
    await file.writeAsString(json);
    if (context.mounted) {
      await SharePlus.instance.share(
        ShareParams(text: L10n.tr('exported', locale), files: [XFile(file.path)]),
      );
    }
  }

  Future<void> _exportGpx(BuildContext context, WidgetRef ref, AppLocale locale,
      RunRecord run) async {
    final gpx = gpxFromRunRecord(run);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, '${run.id}.gpx'));
    await file.writeAsString(gpx);
    if (context.mounted) {
      await SharePlus.instance.share(
        ShareParams(text: L10n.tr('exported', locale), files: [XFile(file.path)]),
      );
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.s8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16, vertical: AppTheme.s8),
          decoration: BoxDecoration(
            color: active ? AppTheme.brand : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.rFull),
          ),
          child: Text(label,
              style: text.labelMedium!.copyWith(
                  color: active ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TextTheme text;
  final ColorScheme cs;
  final AppLocale locale;
  const _EmptyState({required this.text, required this.cs, required this.locale});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded,
                size: 48, color: cs.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: AppTheme.s12),
            Text(L10n.tr('nothing_recorded', locale), style: text.titleMedium),
            const SizedBox(height: AppTheme.s4),
            Text(L10n.tr('first_run_prompt', locale),
                style: text.bodySmall!
                    .copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
          ],
        ),
      );
}

class _ActivityTile extends ConsumerWidget {
  final SampleActivity a;
  final VoidCallback onExportGpx;
  const _ActivityTile({required this.a, required this.onExportGpx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: () => context.go('/activity/${a.id}'),
        onLongPress: () => _maybeDelete(context, ref, a.id),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.r12),
                ),
                child: const Icon(Icons.directions_run_rounded,
                    color: AppTheme.brand),
              ),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.type, style: text.titleMedium),
                    const SizedBox(height: AppTheme.s2),
                    Text(
                      '${formatDistance(a.distanceM)} · ${formatDuration(a.durationMs)}',
                      style: text.bodySmall!
                          .copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.gps_fixed_rounded, size: 20),
                tooltip: L10n.tr('export_gpx', locale),
                onPressed: onExportGpx,
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeDelete(BuildContext context, WidgetRef ref, String id) {
    final locale = ref.read(localeProvider);
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: Text(L10n.tr('delete_activity', locale)),
        content: Text(L10n.tr('delete_activity_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(),
            child: Text(L10n.tr('cancel', locale)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dlg).pop();
              ref.read(activityRepositoryProvider).whenData(
                (repo) => repo.delete(id),
              );
              ref.invalidate(activitiesProvider);
            },
            child: Text(L10n.tr('delete', locale)),
          ),
        ],
      ),
    );
  }
}
