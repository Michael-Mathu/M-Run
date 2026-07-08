import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/onboarding/onboarding_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _page = PageController();
  int _index = 0;

  static const _pages = [
    _Slide(
      icon: Icons.directions_run_rounded,
      title: 'Run with Mwendo',
      body: 'Track every step with a live map, pace and heart rate — all in one screen.',
    ),
    _Slide(
      icon: Icons.emoji_events_rounded,
      title: 'Challenges that stick',
      body: 'Hit your first 5K, build a streak, and watch your XP grow with every run.',
    ),
    _Slide(
      icon: Icons.shield_outlined,
      title: 'Run safe',
      body: 'One tap to alert your emergency contacts with your live location. Always.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? AppTheme.brand : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.s24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
              child: FilledButton(
                onPressed: () {
                  if (_index < _pages.length - 1) {
                    _page.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _finish();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.brand,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(_index < _pages.length - 1 ? 'Next' : 'Get started'),
              ),
            ),
            const SizedBox(height: AppTheme.s32),
          ],
        ),
      ),
    );
  }

  void _finish() async {
    await completeOnboarding();
    ref.invalidate(onboardingDoneProvider);
    if (mounted) context.go('/');
  }
}

class _Slide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Slide({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: Colors.white),
          ),
          const SizedBox(height: AppTheme.s32),
          Text(title, style: text.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.s12),
          Text(body,
              style: text.bodyLarge!
                  .copyWith(color: Colors.white.withValues(alpha: 0.72)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
