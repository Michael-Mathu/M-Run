import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/learn/data/courses.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';
import 'package:mwendo_app/widgets/section_title.dart';
import 'package:mwendo_app/widgets/trailing_chevron.dart';

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final g = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);

    final groups = {
      CourseCategory.science: courses.where((c) => c.category == CourseCategory.science).toList(),
      CourseCategory.technique: courses
          .where((c) => c.category == CourseCategory.technique || c.category == CourseCategory.health)
          .toList(),
      CourseCategory.heritage: courses.where((c) => c.category == CourseCategory.heritage).toList(),
    };

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _Hero(text: text, locale: locale),
                  const SizedBox(height: AppTheme.s24),
                ]),
              ),
            ),
            for (final entry in groups.entries)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s4, AppTheme.s24, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SectionTitle(entry.key.label),
                    const SizedBox(height: AppTheme.s4),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppTheme.s12,
                      crossAxisSpacing: AppTheme.s12,
                      childAspectRatio: 0.82,
                      children: entry.value
                          .map((c) => _CourseCard(
                                course: c,
                                done: g.lessonsCompletedIn(c.slug),
                                locale: locale,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppTheme.s12),
                  ]),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s4, AppTheme.s24, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SectionTitle(L10n.tr('legends', locale)),
                  const SizedBox(height: AppTheme.s4),
                  _LegendsTeaser(locale: locale),
                  const SizedBox(height: AppTheme.s16),
                  SectionTitle(L10n.tr('beat_the_legends', locale)),
                  const SizedBox(height: AppTheme.s4),
                  _BeatTeaser(locale: locale),
                  const SizedBox(height: AppTheme.s32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final TextTheme text;
  final AppLocale locale;
  const _Hero({required this.text, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.r24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brand.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 26),
              const SizedBox(width: AppTheme.s10),
              Text(L10n.tr('academy', locale),
                  style: text.titleLarge!.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: AppTheme.s12),
          Text(
            L10n.tr('learn_hero_body', locale),
            style: text.bodyLarge!.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final int done;
  final AppLocale locale;
  const _CourseCard({required this.course, required this.done, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ratio = course.lessons.isEmpty ? 0.0 : done / course.lessons.length;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: () => context.go('/learn/course/${course.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: course.category.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppTheme.r12),
                ),
                child: Icon(course.category.icon, color: course.category.accent),
              ),
              const SizedBox(height: AppTheme.s12),
              Text(course.title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppTheme.s4),
              Text('${course.lessons.length} ${L10n.tr('lessons', locale)} · ${course.minutes} min',
                  style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
              const Spacer(),
              if (ratio > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.rFull),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 5,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(course.category.accent),
                      ),
                    ),
                    const SizedBox(height: AppTheme.s6),
                    Text('$done/${course.lessons.length} ${L10n.tr('completed', locale)}',
                        style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
                  ],
                )
              else
                Text(L10n.tr('start', locale),
                    style: text.labelMedium!.copyWith(color: AppTheme.brand)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendsTeaser extends StatelessWidget {
  final AppLocale locale;
  const _LegendsTeaser({required this.locale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
        border: Border.all(color: AppTheme.tierGold.withValues(alpha: 0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.r16),
          onTap: () => context.go('/learn/legends'),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Row(
              children: [
                ...legends.take(3).map((l) => Padding(
                      padding: const EdgeInsets.only(right: AppTheme.s8),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: legendAccent(l).withValues(alpha: 0.18),
                        child: Text(l.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    )),
                const SizedBox(width: AppTheme.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${legends.length} ${L10n.tr('legendary_runners', locale)}',
                          style: text.titleMedium),
                      const SizedBox(height: AppTheme.s4),
                      Text(L10n.tr('legends_teaser_sub', locale),
                          style: text.bodySmall!
                              .copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                const TrailingChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BeatTeaser extends StatelessWidget {
  final AppLocale locale;
  const _BeatTeaser({required this.locale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.r16),
          onTap: () => context.push('/beat'),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.brand.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.speed_rounded, color: AppTheme.brand),
                ),
                const SizedBox(width: AppTheme.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(L10n.tr('race_ghost_legend', locale),
                          style: text.titleMedium),
                      const SizedBox(height: AppTheme.s4),
                      Text(L10n.tr('race_ghost_sub', locale),
                          style: text.bodySmall!
                              .copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                const TrailingChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
