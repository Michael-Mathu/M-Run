import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/features/activity/activity_detail_page.dart';
import 'package:mwendo_app/features/activity/activity_list_page.dart';
import 'package:mwendo_app/features/auth/auth_page.dart';
import 'package:mwendo_app/features/beat/beat_legends_page.dart';
import 'package:mwendo_app/features/challenges/challenge_detail_page.dart';
import 'package:mwendo_app/features/challenges/challenge_library_page.dart';
import 'package:mwendo_app/features/home/dashboard_page.dart';
import 'package:mwendo_app/features/learn/course_detail_page.dart';
import 'package:mwendo_app/features/learn/learn_page.dart';
import 'package:mwendo_app/features/learn/legend_detail_page.dart';
import 'package:mwendo_app/features/learn/legends_page.dart';
import 'package:mwendo_app/features/learn/lesson_page.dart';
import 'package:mwendo_app/features/onboarding/onboarding_page.dart';
import 'package:mwendo_app/features/onboarding/onboarding_provider.dart';
import 'package:mwendo_app/features/profile/profile_page.dart';
import 'package:mwendo_app/features/tracking/live_dashboard.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';

GoRouter makeRouter(Ref ref) => GoRouter(
      initialLocation: '/',
      redirect: (context, state) async {
        final done = await ref.read(onboardingDoneProvider.future);
        final loc = state.matchedLocation;
        if (!done && loc != '/onboarding') return '/onboarding';
        if (done && loc == '/onboarding') return '/';
        return null;
      },
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/challenges',
                    builder: (context, state) => const ChallengesLibraryPage()),
                GoRoute(
                  path: '/challenges/:slug',
                  builder: (context, state) =>
                      ChallengeDetailPage(slug: state.pathParameters['slug']!),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/run', builder: (context, state) => const LiveDashboard()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/learn', builder: (context, state) => const LearnPage()),
                GoRoute(
                  path: '/learn/course/:slug',
                  builder: (context, state) =>
                      CourseDetailPage(slug: state.pathParameters['slug']!),
                ),
                GoRoute(
                  path: '/learn/course/:slug/lesson/:index',
                  builder: (context, state) => LessonPage(
                    slug: state.pathParameters['slug']!,
                    index: int.parse(state.pathParameters['index']!),
                  ),
                ),
                GoRoute(
                  path: '/learn/legends',
                  builder: (context, state) => const LegendsPage(),
                ),
                GoRoute(
                  path: '/learn/legends/:slug',
                  builder: (context, state) =>
                      LegendDetailPage(slug: state.pathParameters['slug']!),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/beat',
          builder: (context, state) => const BeatLegendsPage(),
        ),
        GoRoute(
          path: '/beat/:id',
          builder: (context, state) => BeatLegendsPage(id: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityListPage(),
        ),
        GoRoute(
          path: '/activity/:id',
          builder: (context, state) =>
              ActivityDetailPage(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthPage(),
        ),
      ],
    );

final appRouterProvider = Provider<GoRouter>((ref) => makeRouter(ref));

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const ScaffoldWithNavBar({super.key, required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: L10n.tr('home', locale),
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events_rounded),
            label: L10n.tr('challenges', locale),
          ),
          NavigationDestination(
            icon: const _RunNavIcon(),
            selectedIcon: const _RunNavIcon(),
            label: L10n.tr('run', locale),
          ),
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school_rounded),
            label: L10n.tr('learn', locale),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: L10n.tr('profile', locale),
          ),
        ],
      ),
    );
  }
}

class _RunNavIcon extends ConsumerWidget {
  const _RunNavIcon();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording =
        ref.watch(trackingModelProvider).state == AppEngineState.recording;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5A1F), Color(0xFFFF8A3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: recording
            ? const [
                BoxShadow(
                  color: Color(0xFFFF5A1F),
                  blurRadius: 14,
                  spreadRadius: 3,
                ),
              ]
            : const [
                BoxShadow(
                    color: Color(0xFFFF5A1F),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 2)),
              ],
      ),
      child: Icon(
        recording ? Icons.stop_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
