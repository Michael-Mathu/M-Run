import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final slides = [
      _Slide(
        icon: Icons.directions_run_rounded,
        title: L10n.tr('onboarding_run_title', locale),
        body: L10n.tr('onboarding_run_body', locale),
      ),
      _Slide(
        icon: Icons.emoji_events_rounded,
        title: L10n.tr('onboarding_challenges_title', locale),
        body: L10n.tr('onboarding_challenges_body', locale),
      ),
      _Slide(
        icon: Icons.shield_outlined,
        title: L10n.tr('onboarding_safe_title', locale),
        body: L10n.tr('onboarding_safe_body', locale),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(L10n.tr('onboarding_skip', locale)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => slides[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? AppTheme.brand : cs.onSurfaceVariant,
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
                  if (_index < slides.length - 1) {
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
                child: Text(_index < slides.length - 1
                    ? L10n.tr('onboarding_next', locale)
                    : L10n.tr('onboarding_get_started', locale)),
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
    final cs = Theme.of(context).colorScheme;
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
                  .copyWith(color: cs.onSurface.withValues(alpha: 0.72)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
