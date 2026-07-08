import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/utils/haptics.dart';
import 'package:mwendo_app/features/challenges/challenge_evaluator.dart';
import 'package:mwendo_app/features/learn/data/courses.dart';
import 'package:mwendo_app/features/learn/data/legend_of_day.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/widgets/section_title.dart';
import 'package:mwendo_app/widgets/skeleton.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _corruptionShown = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final g = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);
    final recent = ref.watch(activitiesProvider);

    final corrupted = ref.watch(gamificationCorruptedProvider);
    if (corrupted && !_corruptionShown) {
      _corruptionShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.tr('progress_reset', locale)),
              action: SnackBarAction(
                label: L10n.tr('ok', locale),
                onPressed: () {},
              ),
            ),
          );
          ref.read(gamificationCorruptedProvider.notifier).clear();
        }
      });
    }

    final active = ChallengeEvaluator.allChallenges
        .where((c) => !g.completedChallenges.contains(c.slug))
        .take(3)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TopBar(g: g, locale: locale),
                  const SizedBox(height: AppTheme.s24),
                  _WeeklyCard(g: g, text: text, locale: locale),
                  const SizedBox(height: AppTheme.s16),
                  _StartRunButton(),
                  if (g.totalRuns == 0) ...[
                    const SizedBox(height: AppTheme.s16),
                    _FirstRunHint(onTap: () => context.go('/run'), locale: locale),
                  ],
                  const SizedBox(height: AppTheme.s16),
                  const LegendOfDayCard(),
                  const SizedBox(height: AppTheme.s28),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SectionTitle(L10n.tr('active_challenges', locale),
                      actionLabel: L10n.tr('see_all', locale),
                      onAction: () => context.go('/challenges')),
                  const SizedBox(height: AppTheme.s4),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
              sliver: SliverList.separated(
                separatorBuilder: (_, index) => const SizedBox(height: AppTheme.s12),
                itemCount: active.isEmpty ? 1 : active.length,
                itemBuilder: (_, i) {
                  if (active.isEmpty) {
                    return _AllDoneCard(cs: cs, text: text, onTap: () => context.go('/challenges'));
                  }
                  return _DashboardChallengeCard(ch: active[i], g: g, onTap: () => context.push('/challenges/${active[i].slug}'));
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s12, AppTheme.s24, AppTheme.s24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SectionTitle(L10n.tr('continue_learning', locale),
                      actionLabel: L10n.tr('see_all', locale),
                      onAction: () => context.go('/learn')),
                  const SizedBox(height: AppTheme.s4),
                  _LearnRow(),
                  const SizedBox(height: AppTheme.s12),
                  SectionTitle(L10n.tr('recent_activity', locale),
                      actionLabel: L10n.tr('see_all', locale),
                      onAction: () => context.go('/activity')),
                  const SizedBox(height: AppTheme.s4),
                  recent.when(
                    loading: () => const Column(
                      children: [SkeletonCard(height: 88), SizedBox(height: AppTheme.s12), SkeletonCard(height: 88)],
                    ),
                    error: (_, _) => _EmptyActivity(
                        text: text, cs: cs, locale: locale, onWalkRun: () => context.go('/run'), onCourse: () => context.go('/learn/course/how-to-start-running')),
                    data: (runs) => runs.isEmpty
                        ? _EmptyActivity(
                            text: text, cs: cs, locale: locale, onWalkRun: () => context.go('/run'), onCourse: () => context.go('/learn/course/how-to-start-running'))
                        : Column(
                            children: [
                              for (final r in runs.take(3))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: AppTheme.s12),
                                  child: _RecentRunTile(r: r),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppTheme.s24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final GamificationState g;
  final AppLocale locale;
  const _TopBar({required this.g, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(AppTheme.r12),
          ),
          child: const Icon(Icons.directions_run_rounded, color: Colors.white),
        ),
        const SizedBox(width: AppTheme.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.tr('home', locale), style: text.labelMedium),
              Text('Mwendo', style: text.titleLarge),
            ],
          ),
        ),
        if (g.streakDays > 0)
          Semantics(
            label: '${L10n.tr('streak', locale)} ${g.streakDays}',
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.s8),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s4),
              decoration: BoxDecoration(
                color: AppTheme.tierGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppTheme.rFull),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: AppTheme.tierGold, size: 16),
                  const SizedBox(width: AppTheme.s4),
                  Text('${g.streakDays}', style: text.labelMedium!.copyWith(color: AppTheme.tierGold)),
                ],
              ),
            ),
          ),
        Semantics(
          label: '${L10n.tr('level', locale)} ${g.level}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s4),
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppTheme.rFull),
            ),
            child: Text('LV ${g.level}', style: text.labelMedium!.copyWith(color: AppTheme.brand)),
          ),
        ),
      ],
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  final GamificationState g;
  final TextTheme text;
  final AppLocale locale;
  const _WeeklyCard({required this.g, required this.text, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.r24),
        boxShadow: [
          BoxShadow(color: AppTheme.brand.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.tr('this_week', locale), style: text.labelMedium!.copyWith(color: Colors.white70)),
          const SizedBox(height: AppTheme.s4),
          Text(formatDistance(g.totalDistanceM),
              style: text.displayMedium!.copyWith(color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: AppTheme.s20),
          Row(
            children: [
              _Stat(label: L10n.tr('runs', locale), value: g.totalRuns.toString()),
              _Stat(label: L10n.tr('time', locale), value: formatDuration(g.totalTimeMs)),
              _Stat(label: L10n.tr('best', locale), value: g.bestPaceMinPerKm > 0 ? formatPace(g.bestPaceMinPerKm) : '--'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: text.titleLarge!.copyWith(color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: AppTheme.s2),
          Text(label.toUpperCase(), style: text.labelSmall!.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _StartRunButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return FilledButton.icon(
      onPressed: () {
        Haptics.light();
        context.go('/run');
      },
      icon: const Icon(Icons.play_arrow_rounded, size: 24),
      label: Text(L10n.tr('start_run', ref.watch(localeProvider))),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
        textStyle: text.labelLarge!.copyWith(fontSize: 16),
      ),
    );
  }
}

class _FirstRunHint extends StatefulWidget {
  final VoidCallback onTap;
  final AppLocale locale;
  const _FirstRunHint({required this.onTap, required this.locale});

  @override
  State<_FirstRunHint> createState() => _FirstRunHintState();
}

class _FirstRunHintState extends State<_FirstRunHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.s20),
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(AppTheme.r24),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_run_rounded, color: Colors.white, size: 32),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L10n.tr('get_started', widget.locale),
                        style: text.titleMedium!.copyWith(color: Colors.white)),
                    const SizedBox(height: AppTheme.s4),
                    Text(L10n.tr('first_run_hint', widget.locale),
                        style: text.bodySmall!.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardChallengeCard extends StatelessWidget {
  final GamifiedChallenge ch;
  final GamificationState g;
  final VoidCallback onTap;
  const _DashboardChallengeCard({required this.ch, required this.g, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ratio = ch.ratio(g);
    final accent = tierColor(ch.tier);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.surface, accent.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.r16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: () {
          Haptics.light();
          onTap();
        },
        child: Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: tierColor(ch.tier).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(ch.icon, color: tierColor(ch.tier), size: 28),
                ),
                const SizedBox(width: AppTheme.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ch.title, style: text.titleMedium),
                      const SizedBox(height: AppTheme.s2),
                      Text(ch.description, style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppTheme.s8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.rFull),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(tierColor(ch.tier)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.s12),
                Column(
                  children: [
                    Text('+${ch.xp}', style: text.labelMedium!.copyWith(color: tierColor(ch.tier))),
                    Text('XP', style: text.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AllDoneCard extends ConsumerWidget {
  final ColorScheme cs;
  final TextTheme text;
  final VoidCallback onTap;
  const _AllDoneCard({required this.cs, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppTheme.tierGold.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events_rounded, color: AppTheme.tierGold, size: 28),
              ),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L10n.tr('all_caught_up', locale), style: text.titleMedium),
                    const SizedBox(height: AppTheme.s2),
                    Text(L10n.tr('browse_more', locale),
                        style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final picks = courses.take(3).toList();
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: picks.length,
        separatorBuilder: (_, index) => const SizedBox(width: AppTheme.s12),
        itemBuilder: (_, i) {
          final c = picks[i];
          return SizedBox(
            width: 200,
            child: Material(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppTheme.r16),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.r16),
                onTap: () => context.go('/learn/course/${c.slug}'),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.s16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: c.category.accent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(AppTheme.r12)),
                        child: Icon(c.category.icon, color: c.category.accent),
                      ),
                      const SizedBox(width: AppTheme.s12),
                      Expanded(
                        child: Text(c.title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentRunTile extends StatelessWidget {
  final RunRecord r;
  const _RecentRunTile({required this.r});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: () => context.go('/activity/${r.id}'),
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
                child: const Icon(Icons.directions_run_rounded, color: AppTheme.brand),
              ),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.type, style: text.titleMedium),
                    const SizedBox(height: AppTheme.s2),
                    Text(
                      '${formatDistance(r.distanceM)} · ${formatDuration(r.durationMs)}',
                      style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  final TextTheme text;
  final ColorScheme cs;
  final AppLocale locale;
  final VoidCallback? onWalkRun;
  final VoidCallback? onCourse;
  const _EmptyActivity({
    required this.text,
    required this.cs,
    required this.locale,
    this.onWalkRun,
    this.onCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.s32),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppTheme.r16),
            border: Border.all(color: cs.surfaceContainerHighest),
          ),
          child: Column(
            children: [
              const _RunIllustration(),
              const SizedBox(height: AppTheme.s12),
              Text(L10n.tr('no_runs_yet', locale), style: text.titleMedium),
              const SizedBox(height: AppTheme.s4),
              Text(L10n.tr('routes_will_show', locale),
                  style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.55)), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.s12),
        Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppTheme.r16),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.r16),
            onTap: () {
              Haptics.light();
              onCourse?.call();
            },
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.s16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.brand.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.r12),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppTheme.brand, size: 24),
                  ),
                  const SizedBox(width: AppTheme.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(L10n.tr('learn_to_run', locale), style: text.titleMedium),
                        const SizedBox(height: AppTheme.s2),
                        Text(L10n.tr('learn_to_run_hint', locale),
                            style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.s12),
        FilledButton.icon(
          onPressed: () {
            Haptics.light();
            onWalkRun?.call();
          },
          icon: const Icon(Icons.directions_run_rounded, size: 22),
          label: Text(L10n.tr('walk_run_now', locale)),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brand,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
          ),
        ),
      ],
    );
  }
}

/// Lightweight animated illustration for empty states: a bouncing runner on a
/// softly pulsing ring. Pure Flutter, no assets required.
class _RunIllustration extends StatefulWidget {
  const _RunIllustration();

  @override
  State<_RunIllustration> createState() => _RunIllustrationState();
}

class _RunIllustrationState extends State<_RunIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  late final Animation<double> _bob =
      Tween<double>(begin: -4, end: 4).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  late final Animation<double> _ring =
      Tween<double>(begin: 0.55, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      width: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ring,
            builder: (_, _) => Container(
              width: 64 * _ring.value,
              height: 64 * _ring.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brand.withValues(alpha: 0.12 * (1 - _ring.value + 0.4)),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _bob,
            builder: (_, _) => Transform.translate(
              offset: Offset(0, _bob.value),
              child: const Text('🏃', style: TextStyle(fontSize: 36)),
            ),
          ),
        ],
      ),
    );
  }
}
