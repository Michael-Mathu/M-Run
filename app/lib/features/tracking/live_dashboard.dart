import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/utils/haptics.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/network/session_provider.dart';
import 'package:mwendo_app/core/safety/safety_provider.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/maps/offline_map_provider.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/features/beat/ghost_target_provider.dart';
import 'package:mwendo_app/features/challenges/challenge_evaluator.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';
import 'package:mwendo_app/features/safety/safety_service.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';
import 'package:mwendo_app/features/tracking/widgets/metric_tile.dart';
import 'package:mwendo_app/widgets/celebration_overlay.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';

const _kDarkStyle =
    'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';
const _kDefaultCenter = LatLng(-1.2921, 36.8219); // Nairobi

class LiveDashboard extends ConsumerStatefulWidget {
  const LiveDashboard({super.key});

  @override
  ConsumerState<LiveDashboard> createState() => _LiveDashboardState();
}

class _LiveDashboardState extends ConsumerState<LiveDashboard> {
  GamifiedChallenge? _celebrate;
  int _lastMilestone = 0;

  @override
  void initState() {
    super.initState();
    // Recover a run that was interrupted by a crash/kill.
    ref
        .read(trackingModelProvider.notifier)
        .hasRecoverableRun()
        .then((has) {
      if (has) ref.read(trackingModelProvider.notifier).restoreInterrupted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(trackingModelProvider);
    final cs = Theme.of(context).colorScheme;
    final ghost = ref.watch(ghostTargetProvider);
    final mapSource = ref.watch(mapSourceProvider);
    final offlineStyle = ref.watch(offlineMapProvider).value?.style;
    final style = (mapSource == MapSource.offline && offlineStyle != null)
        ? offlineStyle
        : _kDarkStyle;

    // km milestone haptic
    final km = (m.distanceM / 1000).floor();
    if (km > _lastMilestone && km > 0) {
      _lastMilestone = km;
      Haptics.light();
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 58,
                child: Stack(
                  children: [
                    RepaintBoundary(
                      child: _MapView(points: m.trackPoints, styleString: style),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppTheme.s12,
                      left: AppTheme.s16,
                      child: _StatusPill(state: m.state),
                    ),
                    if (ghost != null)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + AppTheme.s12 + 36,
                        left: AppTheme.s16,
                        child: _GhostChip(ghost: ghost, m: m),
                      ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppTheme.s12,
                      right: AppTheme.s16,
                      child: const _SosButton(),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppTheme.s12,
                      right: AppTheme.s16 + 56,
                      child: const _MapToggleButton(),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 42,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.r24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.s24,
                    AppTheme.s20,
                    AppTheme.s24,
                    AppTheme.s24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MetricTile(
                        value: (m.distanceM / 1000).toStringAsFixed(2),
                        unit: 'km',
                        label: 'Distance',
                        accent: AppTheme.brand,
                        hero: true,
                      ),
                      const SizedBox(height: AppTheme.s16),
                      Row(
                        children: [
                          Expanded(
                            child: MetricTile(
                              value: formatPace(m.paceMinPerKm),
                              unit: '/km',
                              label: 'Pace',
                            ),
                          ),
                          Expanded(
                            child: MetricTile(
                              value: formatDuration(m.elapsedMs),
                              unit: '',
                              label: 'Time',
                            ),
                          ),
                          Expanded(
                            child: MetricTile(
                              value: m.heartRate?.toString() ?? '--',
                              unit: 'bpm',
                              label: 'Heart Rate',
                              accent: m.heartRate != null
                                  ? AppTheme.hrZones[math.min(
                                      4,
                                      ((m.heartRate! - 110) ~/ 20).clamp(0, 4),
                                    )]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.s12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricTile(
                              value: m.cadence?.toString() ?? '--',
                              unit: 'spm',
                              label: 'Cadence',
                            ),
                          ),
                          Expanded(
                            child: MetricTile(
                              value: m.elevationGainM.toStringAsFixed(0),
                              unit: 'm',
                              label: 'Elev. Gain',
                            ),
                          ),
                          Expanded(
                            child: MetricTile(
                              value: m.calories.toString(),
                              unit: 'kcal',
                              label: 'Calories',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: AppTheme.s32,
            right: AppTheme.s24,
            child: _ControlCluster(
              state: m.state,
              onStart: () => _requestAndStart(ref, context),
              onPause: () {
                Haptics.light();
                ref.read(trackingModelProvider.notifier).pause();
              },
              onResume: () {
                Haptics.light();
                ref.read(trackingModelProvider.notifier).resume();
              },
              onStop: () => _onStop(ref),
            ),
          ),
          if (_celebrate != null)
            CelebrationOverlay(
              title: _celebrate!.title,
              subtitle: 'Challenge complete · +${_celebrate!.xp} XP',
              onDone: () => setState(() => _celebrate = null),
            ),
        ],
      ),
    );
  }

  Future<void> _requestAndStart(WidgetRef ref, BuildContext context) async {
    Haptics.medium();
    final status = await Permission.locationWhenInUse.request();
    if (status.isPermanentlyDenied) {
      if (context.mounted) _showGpsOverlay(context);
      return;
    }
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission is required to track runs.'),
            action: SnackBarAction(
              label: L10n.tr('open_settings', ref.read(localeProvider)),
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return;
    }
    // Android 10+ throttles a backgrounded foreground `location` service to
    // near-zero updates unless the user grants "Allow all the time". Without
    // this, the run freezes the moment the screen locks.
    final background = await Permission.locationAlways.request();
    if (context.mounted && !background.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Grant "Allow all the time" so tracking continues with the screen off.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
    final notif = await Permission.notification.request();
    if (context.mounted && !notif.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enable notifications so tracking can keep running in the background.',
          ),
        ),
      );
    }
    ref.read(trackingModelProvider.notifier).start();
  }

  /// Full-screen explanation shown when location permission is permanently
  /// denied (Strava-style) so the user understands why it's needed and can
  /// jump straight to system Settings.
  void _showGpsOverlay(BuildContext context) {
    final locale = ref.read(localeProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlg) => Dialog(
        backgroundColor: AppTheme.darkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.r24)),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, color: AppTheme.brand, size: 36),
              ),
              const SizedBox(height: AppTheme.s16),
              Text(L10n.tr('gps_required_title', locale),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.s8),
              Text(L10n.tr('gps_required_body', locale),
                  style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.s20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dlg).pop();
                    openAppSettings();
                  },
                  child: Text(L10n.tr('open_settings', locale)),
                ),
              ),
              const SizedBox(height: AppTheme.s4),
              TextButton(
                onPressed: () => Navigator.of(dlg).pop(),
                child: Text(L10n.tr('cancel', locale)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStop(WidgetRef ref) async {
    Haptics.heavy();
    final m = ref.read(trackingModelProvider);
    final ghost = ref.read(ghostTargetProvider);
    await ref.read(trackingModelProvider.notifier).stop();
    if (m.distanceM < 1) {
      ref.read(ghostTargetProvider.notifier).set(null);
      return;
    }
    final record = runRecordFromSession(
      trackPoints: m.trackPoints,
      distanceM: m.distanceM,
      durationMs: m.elapsedMs,
      elevationGainM: m.elevationGainM,
      calories: m.calories,
    );
    await ref.read(activityRepositoryProvider.future).then((repo) => repo.save(record));
    ref.invalidate(activitiesProvider);
    final userAvgPace = m.distanceM > 0
        ? (m.elapsedMs / 60000) / (m.distanceM / 1000)
        : 0.0;
    final newly = ref.read(gamificationProvider.notifier).completeRun(
          distanceM: m.distanceM,
          durationMs: m.elapsedMs,
          elevationGainM: m.elevationGainM,
          avgPaceMinPerKm: userAvgPace,
        );
    // B2: sync to the leaderboard when signed in; anonymous runs stay local.
    final session = ref.read(sessionProvider);
    if (!session.isAnonymous && mounted) {
      final ok = await ref.read(sessionProvider.notifier).submitRun(
        distanceM: m.distanceM,
        durationMs: m.elapsedMs,
        elevationGainM: m.elevationGainM,
        startedAt: m.trackPoints.isNotEmpty
            ? m.trackPoints.first.timestamp
            : DateTime.now(),
      );
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.tr('submitted', ref.read(localeProvider)))),
        );
      }
    }
    if (ghost != null) {
      final userAvg = (m.elapsedMs / 60000) / (m.distanceM / 1000);
      final beat = userAvg <= ghost.avgPaceMinPerKm;
      final newlyGhost = ref.read(gamificationProvider.notifier).recordBeatLegend(ghost, beat);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(beat
                ? 'You beat ${ghost.name}! 🏆 (${formatPace(userAvg)} vs ${formatPace(ghost.avgPaceMinPerKm)} /km)'
                : '${ghost.name} held you off — you: ${formatPace(userAvg)} /km, ghost: ${formatPace(ghost.avgPaceMinPerKm)} /km'),
          ),
        );
      }
      ref.read(ghostTargetProvider.notifier).set(null);
      if (newlyGhost.isNotEmpty && mounted) {
        setState(() => _celebrate = newlyGhost.first);
      }
    } else if (newly.isNotEmpty && mounted) {
      setState(() => _celebrate = newly.first);
    }
  }
}

class _ControlCluster extends ConsumerWidget {
  final AppEngineState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  const _ControlCluster({
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = state == AppEngineState.recording;
    final idle = state == AppEngineState.idle;
    final mainLabel = idle
        ? L10n.tr('start_run_control', ref.watch(localeProvider))
        : (recording
            ? L10n.tr('pause_run', ref.watch(localeProvider))
            : L10n.tr('resume_run', ref.watch(localeProvider)));
    return Row(
      children: [
        if (recording)
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.s16),
            child: Semantics(
              button: true,
              label: L10n.tr('stop_run', ref.watch(localeProvider)),
              child: FloatingActionButton(
                heroTag: 'stop',
                backgroundColor: AppTheme.sos,
                onPressed: onStop,
                child: const Icon(Icons.stop_rounded, color: Colors.white),
              ),
            ),
          ),
        Semantics(
          button: true,
          label: mainLabel,
          child: FloatingActionButton.large(
            heroTag: 'main',
            backgroundColor: idle
                ? AppTheme.brand
                : (recording ? AppTheme.paused : AppTheme.brand),
            elevation: 8,
            onPressed: () {
              if (idle) {
                onStart();
              } else if (recording) {
                onPause();
              } else {
                onResume();
              }
            },
            child: Icon(
              idle
                  ? Icons.play_arrow_rounded
                  : (recording ? Icons.pause_rounded : Icons.play_arrow_rounded),
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends ConsumerWidget {
  final AppEngineState state;
  const _StatusPill({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final map = {
      AppEngineState.idle: (L10n.tr('ready', locale), AppTheme.idle),
      AppEngineState.recording: (L10n.tr('recording', locale), AppTheme.recording),
      AppEngineState.paused: (L10n.tr('paused', locale), AppTheme.paused),
      AppEngineState.recovering: (L10n.tr('gps_searching', locale), AppTheme.paused),
    };
    final (label, color) = map[state]!;
    final live = state == AppEngineState.recording;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: live
                  ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 2)]
                  : null,
            ),
          ),
          const SizedBox(width: AppTheme.s8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _GhostChip extends ConsumerWidget {
  final GhostPace ghost;
  final TrackingState m;
  const _GhostChip({required this.ghost, required this.m});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final userAvg = m.distanceM > 0
        ? (m.elapsedMs / 60000) / (m.distanceM / 1000)
        : 0.0;
    final delta = userAvg - ghost.avgPaceMinPerKm; // <0 means user is ahead
    final ahead = delta <= 0 && userAvg > 0;
    final color = ahead ? AppTheme.recording : AppTheme.idle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.blur_on_rounded, color: Colors.white, size: 14),
          const SizedBox(width: AppTheme.s6),
           Text(
            '${L10n.tr('ghost_label', locale)} ${formatPace(ghost.avgPaceMinPerKm)} · you ${userAvg > 0 ? formatPace(userAvg) : "--:--"}',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const SizedBox(width: AppTheme.s6),
          Text(
            userAvg > 0 ? '${ahead ? "" : "+"}${formatPace(delta.abs())}' : '',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: color, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

class _SosButton extends ConsumerWidget {
  const _SosButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Semantics(
      button: true,
      label: L10n.tr('sos_button', locale),
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _confirmSos(context, ref),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.shield_outlined, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  void _confirmSos(BuildContext context, WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final contacts = ref.read(safetyContactsProvider);
    if (contacts.isEmpty) {
      showDialog(
        context: context,
        builder: (dlg) => AlertDialog(
          backgroundColor: AppTheme.darkElevated,
          title: Text(L10n.tr('no_emergency_contacts', locale),
              style: const TextStyle(color: Colors.white)),
          content: Text(
            L10n.tr('sos_prompt', locale),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlg).pop(),
              child: Text(L10n.tr('ok', locale)),
            ),
          ],
        ),
      );
      return;
    }

    int remaining = 3;
    late final Timer ticker;
    final countdown = ValueNotifier(remaining);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlg) {
        ticker = Timer.periodic(const Duration(seconds: 1), (t) {
          remaining--;
          countdown.value = remaining;
          if (remaining <= 0) {
            t.cancel();
            Navigator.of(dlg).pop();
            _sendSos(ref);
          }
        });
        return AlertDialog(
          backgroundColor: AppTheme.darkElevated,
          title: Text(L10n.tr('sending_sos', locale), style: const TextStyle(color: Colors.white)),
          content: ValueListenableBuilder<int>(
            valueListenable: countdown,
            builder: (_, v, _) => Text(
              '${L10n.tr('alerting_contacts', locale)}$v…',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ticker.cancel();
                Navigator.of(dlg).pop();
              },
              child: Text(L10n.tr('cancel', locale)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendSos(WidgetRef ref) async {
    final contacts = ref.read(safetyContactsProvider);
    final m = ref.read(trackingModelProvider);
    final last = m.trackPoints.isNotEmpty ? m.trackPoints.last : null;
    final lat = last?.lat ?? _kDefaultCenter.latitude;
    final lng = last?.lng ?? _kDefaultCenter.longitude;
    await SafetyService.sendSos(contacts, lat, lng);
  }
}

class _MapToggleButton extends ConsumerWidget {
  const _MapToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(mapSourceProvider);
    final offlineAvailable = ref.watch(offlineMapProvider).value?.style != null;

    if (!offlineAvailable) return const SizedBox.shrink();

    return Semantics(
      button: true,
      label: L10n.tr('map_toggle', ref.watch(localeProvider)),
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            ref.read(mapSourceProvider.notifier).toggle();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              source == MapSource.offline
                  ? Icons.wifi_off_rounded
                  : Icons.wifi_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapView extends StatefulWidget {
  final List<TrackPoint> points;
  final String styleString;
  const _MapView({required this.points, this.styleString = _kDarkStyle});

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  MapLibreMapController? _ctrl;
  Line? _lineId;
  bool _hasLocationPermission = false;
  bool _isSyncing = false;
  List<LatLng>? _pendingCoords;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await Permission.location.isGranted;
    if (mounted && granted != _hasLocationPermission) {
      setState(() {
        _hasLocationPermission = granted;
      });
    }
  }

  @override
  void didUpdateWidget(covariant _MapView old) {
    super.didUpdateWidget(old);
    _checkPermission();
    if (widget.points != old.points) _syncRoute();
  }

  void _syncRoute() {
    final ctrl = _ctrl;
    if (ctrl == null) return;
    // No drawable path yet — drop any stale line so the map only ever shows
    // the route the user has actually recorded.
    if (widget.points.length < 2) {
      _clearLine();
      return;
    }
    final coords = widget.points
        .map((p) => LatLng(p.lat, p.lng))
        .toList(growable: false);

    if (_isSyncing) {
      _pendingCoords = coords;
      return;
    }

    _isSyncing = true;
    _drawRoute(coords).whenComplete(() {
      _isSyncing = false;
      if (_pendingCoords != null) {
        _pendingCoords = null;
        _syncRoute();
      }
    });
  }

  Future<void> _clearLine() async {
    final ctrl = _ctrl;
    if (ctrl == null || _lineId == null) return;
    final toRemove = _lineId!;
    _lineId = null;
    try {
      await ctrl.removeLine(toRemove);
    } catch (_) {
      // controller may be mid-dispose
    }
  }

  Future<void> _drawRoute(List<LatLng> coords) async {
    final ctrl = _ctrl;
    if (ctrl == null || coords.length < 2) return;
    if (_lineId != null) {
      final toRemove = _lineId!;
      _lineId = null;
      try {
        await ctrl.removeLine(toRemove);
      } catch (_) {}
    }
    _lineId = await ctrl.addLine(
      LineOptions(
        geometry: coords,
        lineColor: '#FE2E4B',
        lineWidth: 6,
        lineOpacity: 0.95,
        lineBlur: 0.5,
      ),
    );
    // Follow the *actual* end of the recorded path. We preserve the user's
    // current zoom (never force 16) and never pan to the raw device fix, so the
    // camera stays locked to the drawn route instead of drifting off it.
    if (coords.isNotEmpty) {
      await ctrl.animateCamera(CameraUpdate.newLatLng(coords.last));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      key: ValueKey(widget.styleString),
      initialCameraPosition: const CameraPosition(
        target: _kDefaultCenter,
        zoom: 12,
      ),
      styleString: widget.styleString,
      myLocationEnabled: _hasLocationPermission,
      // `none` (not `tracking`): the camera must follow the *recorded* route
      // polyline, not the raw device GPS fix. With `tracking`, MapLibre pans to
      // the live fix, which diverges from the drawn line and makes the path
      // look like it isn't following the runner. The blue dot still renders via
      // `myLocationEnabled`.
      myLocationTrackingMode: MyLocationTrackingMode.none,
      onMapCreated: (c) {
        _ctrl = c;
        _syncRoute();
      },
    );
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }
}
