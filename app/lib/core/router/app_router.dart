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
import 'package:mwendo_app/core/utils/haptics.dart';

/// Slide-up + fade page transition used across the app for a snappy,
/// Strava/NRC-like feel: 6% upward slide, 200ms, easeOutCubic.
CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}

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
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) =>
                      _slidePage(state, const DashboardPage()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/challenges',
                  pageBuilder: (context, state) =>
                      _slidePage(state, const ChallengesLibraryPage()),
                ),
                GoRoute(
                  path: '/challenges/:slug',
                  pageBuilder: (context, state) => _slidePage(
                    state,
                    ChallengeDetailPage(slug: state.pathParameters['slug']!),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/run',
                  pageBuilder: (context, state) =>
                      _slidePage(state, const LiveDashboard()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/learn',
                  pageBuilder: (context, state) =>
                      _slidePage(state, const LearnPage()),
                ),
                GoRoute(
                  path: '/learn/course/:slug',
                  pageBuilder: (context, state) => _slidePage(
                    state,
                    CourseDetailPage(slug: state.pathParameters['slug']!),
                  ),
                ),
                GoRoute(
                  path: '/learn/course/:slug/lesson/:index',
                  pageBuilder: (context, state) => _slidePage(
                    state,
                    LessonPage(
                      slug: state.pathParameters['slug']!,
                      index: int.parse(state.pathParameters['index']!),
                    ),
                  ),
                ),
                GoRoute(
                  path: '/learn/legends',
                  pageBuilder: (context, state) =>
                      _slidePage(state, const LegendsPage()),
                ),
                GoRoute(
                  path: '/learn/legends/:slug',
                  pageBuilder: (context, state) => _slidePage(
                    state,
                    LegendDetailPage(slug: state.pathParameters['slug']!),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  pageBuilder: (context, state) =>
                      _slidePage(state, const ProfilePage()),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/beat',
          pageBuilder: (context, state) =>
              _slidePage(state, const BeatLegendsPage()),
        ),
        GoRoute(
          path: '/beat/:id',
          pageBuilder: (context, state) => _slidePage(
            state,
            BeatLegendsPage(id: state.pathParameters['id']),
          ),
        ),
        GoRoute(
          path: '/activity',
          pageBuilder: (context, state) =>
              _slidePage(state, const ActivityListPage()),
        ),
        GoRoute(
          path: '/activity/:id',
          pageBuilder: (context, state) => _slidePage(
            state,
            ActivityDetailPage(id: state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) =>
              _slidePage(state, const OnboardingPage()),
        ),
        GoRoute(
          path: '/auth',
          pageBuilder: (context, state) =>
              _slidePage(state, const AuthPage()),
        ),
      ],
    );

final appRouterProvider = Provider<GoRouter>((ref) => makeRouter(ref));

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const ScaffoldWithNavBar({super.key, required this.shell});

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  // Swipe-to-switch-tab: detect a horizontal fling on the shell body and move
  // to the adjacent branch. Lightweight alternative to wrapping the shell in a
  // PageView, which would fight StatefulShellRoute's internal navigators.
  static const _branchCount = 5;

  void _onHorizontalDragEnd(DragEndDetails details) {
    final v = details.primaryVelocity;
    if (v == null || v.abs() < 300) return;
    final i = widget.shell.currentIndex;
    final next = v < 0 ? i + 1 : i - 1;
    if (next >= 0 && next < _branchCount) widget.shell.goBranch(next);
  }

  Widget _destination({
    required Widget icon,
    required Widget selectedIcon,
    required String label,
  }) =>
      NavigationDestination(
        icon: Opacity(opacity: 0.6, child: icon),
        selectedIcon: Transform.scale(scale: 1.15, child: selectedIcon),
        label: label,
      );

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final runTabVisible = widget.shell.currentIndex == 2;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // System back button: go to home tab if not already there.
          if (widget.shell.currentIndex != 0) {
            widget.shell.goBranch(0);
          }
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onHorizontalDragEnd: _onHorizontalDragEnd,
          behavior: HitTestBehavior.translucent,
          child: widget.shell,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.shell.currentIndex,
          onDestinationSelected: (i) {
            if (i != widget.shell.currentIndex) Haptics.selection();
            widget.shell.goBranch(i);
          },
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _destination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: L10n.tr('home', locale),
            ),
            _destination(
              icon: const Icon(Icons.emoji_events_outlined),
              selectedIcon: const Icon(Icons.emoji_events_rounded),
              label: L10n.tr('challenges', locale),
            ),
            NavigationDestination(
              icon: _RunNavIcon(runTabVisible: runTabVisible),
              selectedIcon: _RunNavIcon(runTabVisible: runTabVisible),
              label: L10n.tr('run', locale),
            ),
            _destination(
              icon: const Icon(Icons.school_outlined),
              selectedIcon: const Icon(Icons.school_rounded),
              label: L10n.tr('learn', locale),
            ),
            _destination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: L10n.tr('profile', locale),
            ),
          ],
        ),
      ),
    );
  }
}

/// Run tab icon. When not recording it emits a soft pulsing glow (attract
/// mode); once recording the glow steadies into a solid red pulse.
/// Pauses animation when the run tab is not visible to save CPU.
class _RunNavIcon extends ConsumerStatefulWidget {
  final bool runTabVisible;
  const _RunNavIcon({this.runTabVisible = true});

  @override
  ConsumerState<_RunNavIcon> createState() => _RunNavIconState();
}

class _RunNavIconState extends ConsumerState<_RunNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.runTabVisible) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _RunNavIcon old) {
    super.didUpdateWidget(old);
    if (widget.runTabVisible && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.runTabVisible && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recording =
        ref.watch(trackingModelProvider).state == AppEngineState.recording;
    const base = Color(0xFFFF5A1F);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glow = recording ? 0.0 : (_pulse.value * 8 + 6);
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
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: recording ? 1.0 : 0.5),
                blurRadius: recording ? 14 : glow,
                spreadRadius: recording ? 3 : glow * 0.4,
              ),
            ],
          ),
          child: Icon(
            recording ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 26,
          ),
        );
      },
    );
  }
}