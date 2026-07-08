import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';

class LegendDetailPage extends StatelessWidget {
  final String slug;
  const LegendDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final l = legendForSlug(slug);
    final accent = legendAccent(l);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(AppTheme.s24, MediaQuery.of(context).padding.top + AppTheme.s16, AppTheme.s24, AppTheme.s24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.9), accent.withValues(alpha: 0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(l.emoji, style: const TextStyle(fontSize: 36)),
                      ),
                      const SizedBox(width: AppTheme.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.name,
                                style: text.headlineLarge!.copyWith(color: Colors.white)),
                            const SizedBox(height: AppTheme.s4),
                            Row(
                              children: [
                                Text(l.flag, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: AppTheme.s6),
                                Text('${l.country} · ${l.discipline}',
                                    style: text.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.s16),
                  Text(l.tagline,
                      style: text.titleMedium!.copyWith(color: Colors.white.withValues(alpha: 0.95))),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Biography', style: text.titleLarge),
                const SizedBox(height: AppTheme.s8),
                Text(l.bio, style: text.bodyLarge!.copyWith(height: 1.6)),
                const SizedBox(height: AppTheme.s24),
                Text('Career Timeline', style: text.titleLarge),
                const SizedBox(height: AppTheme.s12),
                ...l.timeline.map((m) => _TimelineRow(year: m.year, text: m.text, accent: accent)),
                const SizedBox(height: AppTheme.s24),
                Text('Records', style: text.titleLarge),
                const SizedBox(height: AppTheme.s12),
                ...l.records.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.s8),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events_rounded, color: AppTheme.tierGold, size: 20),
                          const SizedBox(width: AppTheme.s12),
                          Expanded(child: Text(r, style: text.bodyMedium)),
                        ],
                      ),
                    )),
                const SizedBox(height: AppTheme.s24),
                Text('In Their Words', style: text.titleLarge),
                const SizedBox(height: AppTheme.s12),
                ...l.quotes.map((q) => Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.s12),
                      padding: const EdgeInsets.all(AppTheme.s16),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.r16),
                        border: Border.all(color: accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('“',
                              style: text.displayMedium!.copyWith(color: accent, height: 0.6)),
                          const SizedBox(width: AppTheme.s8),
                          Expanded(
                            child: Text(q,
                                style: text.titleMedium!.copyWith(fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: AppTheme.s12),
                if (l.beatLegendId != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go('/beat/${l.beatLegendId}'),
                      icon: const Icon(Icons.speed_rounded),
                      label: const Text('Challenge me'),
                      style: FilledButton.styleFrom(backgroundColor: accent),
                    ),
                  ),
                const SizedBox(height: AppTheme.s24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String year;
  final String text;
  final Color accent;
  const _TimelineRow({required this.year, required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(year,
                style: textTheme.labelMedium!.copyWith(color: accent, fontWeight: FontWeight.w700)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 6, right: AppTheme.s12),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(color: cs.surface, width: 2),
            ),
          ),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
