import 'package:flutter/material.dart';
import 'legends.dart';

/// A "ghost runner" — a legendary performance you can race against (Pillar 4).
/// [splits] are seconds-per-segment across [distanceKm]; the count is chosen so
/// each segment is roughly a kilometre (shorter races use finer segments).
class GhostPace {
  final String id;
  final String legendSlug;
  final String name;
  final String distanceLabel;
  final double distanceKm;
  final List<double> splits; // seconds per segment
  final int totalSeconds;
  final String description;
  final Color accent;

  const GhostPace({
    required this.id,
    required this.legendSlug,
    required this.name,
    required this.distanceLabel,
    required this.distanceKm,
    required this.splits,
    required this.totalSeconds,
    required this.description,
    required this.accent,
  });

  double get avgPaceMinPerKm => totalSeconds / 60 / distanceKm;
  Legend get legend => legendForSlug(legendSlug);
}

List<double> _buildSplits(double distanceKm, int totalSeconds, String style) {
  final n = distanceKm >= 5 ? distanceKm.round() : (distanceKm * 2).round();
  final base = totalSeconds / n;
  final out = <double>[];
  for (int i = 0; i < n; i++) {
    final t = (i + 1) / n;
    double factor;
    switch (style) {
      case 'positive':
        factor = 0.9 + 0.2 * t;
        break;
      case 'negative':
        factor = 1.12 - 0.24 * t;
        break;
      default:
        factor = 1.0 + 0.02 * (i.isEven ? 1 : -1);
    }
    out.add(base * factor);
  }
  final sum = out.fold(0.0, (a, b) => a + b);
  return out.map((s) => s * totalSeconds / sum).toList();
}

List<GhostPace> get ghostPaces => [
      GhostPace(
        id: 'kipchoge-marathon',
        legendSlug: 'eliud-kipchoge',
        name: 'Kipchoge — Berlin 2022',
        distanceLabel: 'Marathon',
        distanceKm: 42.195,
        totalSeconds: 7269, // 2:01:09
        splits: _buildSplits(42.195, 7269, 'positive'),
        description:
            'The official marathon world record. A metronomic, slightly positive split — the model of controlled excellence.',
        accent: const Color(0xFFFF5A1F),
      ),
      GhostPace(
        id: 'kiptum-marathon',
        legendSlug: 'kelvin-kiptum',
        name: 'Kiptum — Chicago 2023',
        distanceLabel: 'Marathon',
        distanceKm: 42.195,
        totalSeconds: 7235, // 2:00:35
        splits: _buildSplits(42.195, 7235, 'negative'),
        description:
            'The fastest marathon ever run. An aggressive negative split that rewrote the limits of human endurance.',
        accent: const Color(0xFFFF5A1F),
      ),
      GhostPace(
        id: 'tergat-10k',
        legendSlug: 'paul-tergat',
        name: 'Tergat — 10,000m',
        distanceLabel: '10K',
        distanceKm: 10,
        totalSeconds: 1588, // 26:27.85
        splits: _buildSplits(10, 1588, 'even'),
        description:
            'Paul Tergat\'s iconic track 10,000m. Even, relentless, and historically dominant.',
        accent: const Color(0xFFFF5A1F),
      ),
      GhostPace(
        id: 'kipyegon-1500',
        legendSlug: 'faith-kipyegon',
        name: 'Kipyegon — 1500m',
        distanceLabel: '1500m',
        distanceKm: 1.5,
        totalSeconds: 229, // 3:48.68
        splits: _buildSplits(1.5, 229, 'even'),
        description:
            'The queen of the mile at world-record pace. Two searing laps of the track.',
        accent: const Color(0xFFFF5A1F),
      ),
      GhostPace(
        id: 'chebet-5000',
        legendSlug: 'beatrice-chebet',
        name: 'Chebet — 5000m',
        distanceLabel: '5000m',
        distanceKm: 5,
        totalSeconds: 845, // 14:05.20
        splits: _buildSplits(5, 845, 'even'),
        description:
            'The women\'s 5000m world record. Smooth, fast, and fearless from the gun.',
        accent: const Color(0xFFFF5A1F),
      ),
    ];

GhostPace ghostPaceForId(String id) =>
    ghostPaces.firstWhere((g) => g.id == id, orElse: () => ghostPaces.first);
