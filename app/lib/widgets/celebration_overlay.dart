import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Full-screen confetti burst used for challenge completions / run milestones.
class CelebrationOverlay extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onDone;

  const CelebrationOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    this.onDone,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late final ConfettiController _c = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _c.play();
    Future.delayed(const Duration(seconds: 3), () => widget.onDone?.call());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _c,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 40,
            gravity: 0.4,
            colors: const [
              Color(0xFFFF5A1F),
              Color(0xFFFFD15C),
              Color(0xFF2BB673),
              Color(0xFF4A90E2),
              Colors.white,
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded,
                  size: 72, color: Color(0xFFFFD15C)),
              const SizedBox(height: AppTheme.s16),
              Text(widget.title,
                  style: text.headlineLarge!
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.s8),
              Text(widget.subtitle,
                  style: text.bodyLarge!
                      .copyWith(color: Colors.white70),
                  textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }
}