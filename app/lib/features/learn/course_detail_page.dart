import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/learn/data/courses.dart';

class CourseDetailPage extends ConsumerWidget {
  final String slug;
  const CourseDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = courseForSlug(slug);
    final g = ref.watch(gamificationProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final done = g.lessonsCompletedIn(course.slug);
    final ratio = course.lessons.isEmpty ? 0.0 : done / course.lessons.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(AppTheme.s20),
                  decoration: BoxDecoration(
                    color: course.category.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppTheme.r16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(course.category.icon, color: course.category.accent, size: 32),
                      const SizedBox(height: AppTheme.s12),
                      Text(course.subtitle, style: text.titleMedium),
                      const SizedBox(height: AppTheme.s8),
                      Text('By ${course.author} · ${course.minutes} min', style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: AppTheme.s16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.rFull),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(course.category.accent),
                        ),
                      ),
                      const SizedBox(height: AppTheme.s6),
                      Text('$done of ${course.lessons.length} lessons complete',
                          style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.s16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, 0, AppTheme.s24, AppTheme.s24),
            sliver: SliverList.separated(
              separatorBuilder: (_, index) => const SizedBox(height: AppTheme.s12),
              itemCount: course.lessons.length,
              itemBuilder: (_, i) {
                final lesson = course.lessons[i];
                final isDone = g.isLessonDone(course.slug, i);
                return Material(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppTheme.r16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.r16),
                    onTap: () => context.go('/learn/course/${course.slug}/lesson/$i'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.s16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppTheme.tierGold.withValues(alpha: 0.18)
                                  : cs.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDone ? Icons.check_rounded : Icons.menu_book_rounded,
                              color: isDone ? AppTheme.tierGold : cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: AppTheme.s16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lesson.title, style: text.titleMedium),
                                const SizedBox(height: AppTheme.s2),
                                Text('${lesson.minutes} min · ${lesson.summary}',
                                    style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
