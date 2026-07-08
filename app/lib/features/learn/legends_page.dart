import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';

class LegendsPage extends StatefulWidget {
  const LegendsPage({super.key});

  @override
  State<LegendsPage> createState() => _LegendsPageState();
}

class _LegendsPageState extends State<LegendsPage> {
  final _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = legends.where((l) {
      final q = _query.toLowerCase();
      return q.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.country.toLowerCase().contains(q) ||
          l.discipline.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Legends'), centerTitle: false),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppTheme.r12),
                  ),
                  child: TextField(
                    controller: _q,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search legends, countries…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: AppTheme.s12),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.s16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, 0, AppTheme.s24, AppTheme.s24),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppTheme.s12,
              crossAxisSpacing: AppTheme.s12,
              childAspectRatio: 0.92,
              children: items.map((l) => _LegendCard(legend: l)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  final Legend legend;
  const _LegendCard({required this.legend});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final accent = legendAccent(legend);
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: () => context.go('/learn/legends/${legend.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accent.withValues(alpha: 0.18),
                    child: Text(legend.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const Spacer(),
                  Text(legend.flag, style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: AppTheme.s12),
              Text(legend.name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppTheme.s2),
              Text(legend.discipline,
                  style: text.labelSmall!.copyWith(color: accent, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(legend.country,
                  style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
            ],
          ),
        ),
      ),
    );
  }
}
