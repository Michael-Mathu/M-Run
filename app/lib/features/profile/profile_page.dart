import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/gamification/leaderboard_data.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/network/leaderboard_provider.dart';
import 'package:mwendo_app/core/network/session_provider.dart';
import 'package:mwendo_app/core/profile/profile_provider.dart';
import 'package:mwendo_app/core/safety/safety_provider.dart';
import 'package:mwendo_app/data/gpx_export.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/features/safety/safety_service.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/theme/theme_mode_provider.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/features/challenges/challenge_evaluator.dart';
import 'package:mwendo_app/widgets/level_ring.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    final profile = ref.watch(userProfileProvider);
    final units = ref.watch(unitsProvider);
    final contacts = ref.watch(safetyContactsProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final board = ref.watch(remoteLeaderboardProvider(g.xp)).when(
      data: (b) => b,
      loading: () => leaderboardWithUser(g.xp),
      error: (_, _) => leaderboardWithUser(g.xp),
    ).take(5).toList();
    final rank = board.indexWhere((e) => e.you) + 1;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.s24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _EditPhotoSheet.show(context, ref),
                        child: profile.photoPath != null
                            ? CircleAvatar(
                                radius: 34,
                                backgroundImage: FileImage(File(profile.photoPath!)),
                              )
                            : const CircleAvatar(
                                radius: 34,
                                backgroundColor: AppTheme.brand,
                                child: Icon(Icons.person_rounded, color: Colors.white, size: 36),
                              ),
                      ),
                      const SizedBox(width: AppTheme.s16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _EditNameSheet.show(context, ref, profile.username),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.username, style: text.headlineLarge),
                              Text('Level ${g.level} · ${g.title}',
                                  style: text.bodyMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                      ),
                      LevelRing(level: g.level, progress: g.levelProgress, size: 56),
                    ],
                  ),
                  const SizedBox(height: AppTheme.s16),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.s16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(AppTheme.r16),
                    ),
                    child: XpBar(
                      xpIntoLevel: g.xpIntoLevel,
                      xpForNextLevel: g.xpForNextLevel,
                      progress: g.levelProgress,
                    ),
                  ),
                  const SizedBox(height: AppTheme.s16),
                  Row(
                    children: [
                      _StatTile(label: L10n.tr('distance', locale), value: formatDistanceUnits(g.totalDistanceM, units)),
                      _StatTile(label: L10n.tr('runs', locale), value: g.totalRuns.toString()),
                      _StatTile(label: L10n.tr('time', locale), value: formatDuration(g.totalTimeMs)),
                      _StatTile(label: L10n.tr('streak', locale), value: '${g.streakDays}d'),
                    ],
                  ),
                  const SizedBox(height: AppTheme.s28),
                  SectionHeader(L10n.tr('achievements', locale)),
                  const SizedBox(height: AppTheme.s12),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
              sliver: g.earnedBadges.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.s20),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(AppTheme.r16),
                        ),
                        child: Text(
                          L10n.tr('no_badges_yet', locale),
                          style: text.bodyMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                        ),
                      ),
                    )
                  : SliverGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: AppTheme.s12,
                      crossAxisSpacing: AppTheme.s12,
                      childAspectRatio: 0.8,
                      children: g.earnedBadges
                          .map((id) => _BadgeTile(id: id))
                          .toList(),
                    ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.s24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (g.titles.isNotEmpty) ...[
                    SectionHeader(L10n.tr('titles', locale)),
                    const SizedBox(height: AppTheme.s12),
                    Wrap(
                      spacing: AppTheme.s8,
                      runSpacing: AppTheme.s8,
                      children: g.titles
                          .map((t) => Chip(
                                label: Text(t,
                                    style: text.labelMedium!.copyWith(color: AppTheme.brand)),
                                backgroundColor: AppTheme.brand.withValues(alpha: 0.14),
                                side: BorderSide.none,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppTheme.s28),
                  ],
                  SectionHeader('${L10n.tr('leaderboard', locale)} · Rank #$rank'),
                  const SizedBox(height: AppTheme.s12),
                  ...board.map((e) => _LeaderRow(e: e, text: text, cs: cs)),
                  const SizedBox(height: AppTheme.s28),
                  SectionHeader(L10n.tr('account', locale)),
                  const SizedBox(height: AppTheme.s12),
                  _AccountTile(),
                  const SizedBox(height: AppTheme.s28),
                  SectionHeader(L10n.tr('settings', locale)),
                  const SizedBox(height: AppTheme.s12),
                  _LangTile(cs: cs, text: text, ref: ref, locale: locale),
                  _SettingTile(
                    icon: Icons.straighten_rounded,
                    title: L10n.tr('units', locale),
                    subtitle: units == Units.metric
                        ? L10n.tr('metric', locale)
                        : L10n.tr('imperial', locale),
                    onTap: () => ref.read(unitsProvider.notifier).toggle(),
                  ),
                  _SettingTile(
                    icon: Icons.brightness_6_rounded,
                    title: L10n.tr('appearance', locale),
                    subtitle: mode == ThemeMode.dark
                        ? L10n.tr('dark', locale)
                        : (mode == ThemeMode.light
                            ? L10n.tr('light', locale)
                            : L10n.tr('system', locale)),
                    onTap: () => ref.read(themeModeProvider.notifier).cycle(),
                  ),
                  _SettingTile(
                    icon: Icons.shield_outlined,
                    title: L10n.tr('emergency_contacts', locale),
                    subtitle: contacts.isEmpty
                        ? L10n.tr('not_set', locale)
                        : '${contacts.length} ${L10n.tr('emergency_contacts', locale)}',
                    onTap: () => _EmergencyContactsSheet.show(context, ref),
                  ),
                  _SettingTile(
                    icon: Icons.file_download_outlined,
                    title: L10n.tr('export_data', locale),
                    onTap: () => _exportData(context, ref, locale),
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

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleLarge);
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.s16),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(AppTheme.r12)),
        child: Column(
          children: [
            Text(value, style: text.titleLarge!.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            const SizedBox(height: AppTheme.s4),
            Text(label.toUpperCase(), style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String id;
  const _BadgeTile({required this.id});

  @override
  Widget build(BuildContext context) {
    final meta = badgeMeta(id);
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(AppTheme.r16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(meta.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: AppTheme.s6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4),
            child: Text(meta.name, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry e;
  final TextTheme text;
  final ColorScheme cs;
  const _LeaderRow({required this.e, required this.text, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.s8),
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: e.you ? AppTheme.brand.withValues(alpha: 0.14) : cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r12),
      ),
      child: Row(
        children: [
          Text(e.flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppTheme.s12),
          Expanded(child: Text(e.name, style: text.titleMedium)),
          Text('${e.xp} XP', style: text.labelMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final locale = ref.watch(localeProvider);
    final session = ref.watch(sessionProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4, vertical: AppTheme.s8),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(AppTheme.r12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppTheme.r12)),
            child: Icon(session.isAnonymous ? Icons.person_outline_rounded : Icons.verified_user_rounded,
                color: AppTheme.brand),
          ),
          const SizedBox(width: AppTheme.s16),
          Expanded(
            child: session.isAnonymous
                ? Text(L10n.tr('continue_anonymous', locale), style: text.titleMedium)
                : Text(session.email ?? L10n.tr('account', locale), style: text.titleMedium),
          ),
          TextButton(
            onPressed: () {
              if (session.isAnonymous) {
                context.push('/auth');
              } else {
                ref.read(sessionProvider.notifier).logout();
              }
            },
            child: Text(session.isAnonymous
                ? L10n.tr('sign_in', locale)
                : L10n.tr('sign_out', locale)),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme text;
  final WidgetRef ref;
  final AppLocale locale;
  const _LangTile({required this.cs, required this.text, required this.ref, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4, vertical: AppTheme.s8),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(AppTheme.r12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppTheme.r12)),
            child: Icon(Icons.language_rounded, color: AppTheme.brand),
          ),
          const SizedBox(width: AppTheme.s16),
          Expanded(child: Text(L10n.tr('language', locale), style: text.titleMedium)),
          SegmentedButton<AppLocale>(
            selected: {locale},
            showSelectedIcon: false,
            onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(s.first),
            segments: const [
              ButtonSegment(value: AppLocale.english, label: Text('EN')),
              ButtonSegment(value: AppLocale.swahili, label: Text('SW')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _SettingTile({required this.icon, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final child = ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppTheme.r12)),
        child: Icon(icon, color: AppTheme.brand),
      ),
      title: Text(title, style: text.titleMedium),
      subtitle: subtitle != null ? Text(subtitle!, style: text.bodySmall) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
    );
    if (onTap == null) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.r12),
      onTap: onTap,
      child: child,
    );
  }
}

Future<void> _exportData(
    BuildContext context, WidgetRef ref, AppLocale locale) async {
  final repo = await ref.read(activityRepositoryProvider.future);
  final runs = await repo.list();
  if (runs.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.tr('nothing_recorded', locale))),
      );
    }
    return;
  }
  final json = jsonFromRuns(runs);
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, 'mwendo_activities.json'));
  await file.writeAsString(json);
  if (context.mounted) {
    await SharePlus.instance.share(
      ShareParams(
        text: L10n.tr('exported', locale),
        files: [XFile(file.path)],
      ),
    );
  }
}

/// Edit the display name.
class _EditNameSheet {
  static void show(BuildContext context, WidgetRef ref, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: Text(L10n.tr('name', ref.read(localeProvider))),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(labelText: L10n.tr('name', ref.read(localeProvider))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(),
            child: Text(L10n.tr('cancel', ref.read(localeProvider))),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).setUsername(ctrl.text);
              Navigator.of(dlg).pop();
            },
            child: Text(L10n.tr('save', ref.read(localeProvider))),
          ),
        ],
      ),
    );
  }
}

/// Pick or remove a profile photo.
class _EditPhotoSheet {
  static void show(BuildContext context, WidgetRef ref) {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
      ),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Camera'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.camera);
                if (img != null) {
                  await ref.read(userProfileProvider.notifier).setPhoto(img.path);
                }
                if (context.mounted) Navigator.of(sheet).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.gallery);
                if (img != null) {
                  await ref.read(userProfileProvider.notifier).setPhoto(img.path);
                }
                if (context.mounted) Navigator.of(sheet).pop();
              },
            ),
            if (ref.read(userProfileProvider).photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Remove photo'),
                onTap: () async {
                  await ref.read(userProfileProvider.notifier).setPhoto(null);
                  if (context.mounted) Navigator.of(sheet).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet to add, edit and remove emergency contacts. Persists via
/// [safetyContactsProvider] so the SOS flow can reach them.
class _EmergencyContactsSheet {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
      ),
      builder: (sheet) => Padding(
        padding: EdgeInsets.only(
          left: AppTheme.s24,
          right: AppTheme.s24,
          top: AppTheme.s24,
          bottom: AppTheme.s24 + MediaQuery.of(sheet).viewInsets.bottom,
        ),
        child: const _EmergencyContactsBody(),
      ),
    );
  }
}

class _EmergencyContactsBody extends ConsumerWidget {
  const _EmergencyContactsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(safetyContactsProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
        children: [
          Text(L10n.tr('emergency_contacts', locale), style: text.titleLarge),
            const Spacer(),
          TextButton.icon(
            onPressed: () => _editContact(context, ref, null, locale),
            icon: const Icon(Icons.add_rounded),
            label: Text(L10n.tr('add_contact', locale)),
          ),
          ],
        ),
        const SizedBox(height: AppTheme.s12),
            if (contacts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
                child: Text(L10n.tr('no_contacts_yet', locale),
                    style: text.bodyMedium!.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6))),
              )
            else
          ListView.separated(
            shrinkWrap: true,
            itemCount: contacts.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppTheme.s8),
            itemBuilder: (_, i) {
              final c = contacts[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_rounded, color: AppTheme.brand),
                title: Text(c.name),
                subtitle: Text('${c.relationship} · ${c.phone}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editContact(context, ref, i, locale),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () =>
                          ref.read(safetyContactsProvider.notifier).removeAt(i),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _editContact(BuildContext context, WidgetRef ref, int? index, AppLocale locale) {
    final editing = index == null ? null : ref.read(safetyContactsProvider)[index];
    final nameCtrl = TextEditingController(text: editing?.name);
    final phoneCtrl = TextEditingController(text: editing?.phone);
    final relCtrl = TextEditingController(text: editing?.relationship);

    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: Text(index == null ? L10n.tr('add_contact', locale) : L10n.tr('edit_contact', locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: L10n.tr('name', locale)),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: L10n.tr('phone', locale)),
            ),
            TextField(
              controller: relCtrl,
              decoration: InputDecoration(labelText: L10n.tr('relationship', locale)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(),
            child: Text(L10n.tr('cancel', locale)),
          ),
          TextButton(
            onPressed: () {
              final contact = EmergencyContact(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                relationship: relCtrl.text.trim(),
              );
              final notifier = ref.read(safetyContactsProvider.notifier);
              if (index == null) {
                notifier.add(contact);
              } else {
                notifier.update(index, contact);
              }
              Navigator.of(dlg).pop();
            },
            child: Text(L10n.tr('save', locale)),
          ),
        ],
      ),
    );
  }
}
