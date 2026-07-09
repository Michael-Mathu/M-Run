import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';

enum AppEngineState { idle, recording, paused, recovering }

class TrackingState {
  final AppEngineState state;
  final double distanceM;
  final int elapsedMs;
  final int movingTimeMs;
  final double paceMinPerKm; // 0 = unknown
  final int? heartRate;
  final int? cadence;
  final double elevationGainM;
  final int calories;
  final List<TrackPoint> trackPoints;

  const TrackingState({
    required this.state,
    this.distanceM = 0,
    this.elapsedMs = 0,
    this.movingTimeMs = 0,
    this.paceMinPerKm = 0,
    this.heartRate,
    this.cadence,
    this.elevationGainM = 0,
    this.calories = 0,
    this.trackPoints = const [],
  });

  static const initial = TrackingState(state: AppEngineState.idle);

  TrackingState copyWith({
    AppEngineState? state,
    double? distanceM,
    int? elapsedMs,
    int? movingTimeMs,
    double? paceMinPerKm,
    int? heartRate,
    int? cadence,
    double? elevationGainM,
    int? calories,
    List<TrackPoint>? trackPoints,
  }) =>
      TrackingState(
        state: state ?? this.state,
        distanceM: distanceM ?? this.distanceM,
        elapsedMs: elapsedMs ?? this.elapsedMs,
        movingTimeMs: movingTimeMs ?? this.movingTimeMs,
        paceMinPerKm: paceMinPerKm ?? this.paceMinPerKm,
        heartRate: heartRate ?? this.heartRate,
        cadence: cadence ?? this.cadence,
        elevationGainM: elevationGainM ?? this.elevationGainM,
        calories: calories ?? this.calories,
        trackPoints: trackPoints ?? this.trackPoints,
      );
}

class TrackingModel extends Notifier<TrackingState> {
  final _engine = MwendoGpsEngine();
  final List<TrackPoint> _pts = [];
  double _elevationGain = 0;
  Timer? _ticker;
  DateTime? _runStart;
  int _accumulatedMs = 0;
  int _accumulatedMovingMs = 0;
  DateTime? _movingStart;
  StreamSubscription<TrackPoint>? _sub;

  // Serial command queue — prevents start/stop/pause race conditions during
  // rapid pause/resume cycles (blueprint: "lock start/stop commands").
  Future<void>? _lock;

  @override
  TrackingState build() {
    ref.onDispose(() => _ticker?.cancel());
    return TrackingState.initial;
  }

  /// Drives `elapsedMs` from the wall clock so the timer ticks live regardless
  /// of GPS quality. GPS only feeds distance/pace; the clock is independent.
  void _startTicker() {
    _runStart = DateTime.now();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_runStart == null) return;
      final total =
          _accumulatedMs + DateTime.now().difference(_runStart!).inMilliseconds;
      // Moving time only counts when speed > 0.3 m/s
      int movingMs = _accumulatedMovingMs;
      if (_movingStart != null && _pts.isNotEmpty) {
        final lastSpeed = _pts.last.speedMps;
        if (lastSpeed > 0.3) {
          movingMs += DateTime.now().difference(_movingStart!).inMilliseconds;
        }
      }
      state = state.copyWith(
        elapsedMs: total,
        movingTimeMs: movingMs,
        calories: (total / 60000 * 11).round(),
      );
    });
  }

  void _stopTicker({bool isPaused = false}) {
    _ticker?.cancel();
    _ticker = null;
    if (_runStart != null) {
      _accumulatedMs += DateTime.now().difference(_runStart!).inMilliseconds;
      _runStart = null;
      if (!isPaused && _pts.isNotEmpty && _pts.last.speedMps > 0.3) {
        _accumulatedMovingMs = state.movingTimeMs;
      }
      _movingStart = null;
    }
  }

  File _recoveryFile() {
    // ponytail: a single JSON file is the simplest crash-recovery store; swap
    // for the Drift-backed table when ActivityRepository is migrated.
    final dir = Directory.systemTemp;
    return File(p.join(dir.path, 'mwendo_recovery.json'));
  }

  Future<void> _writeRecovery() async {
    try {
      final data = _pts
          .map((t) => {
                'lat': t.lat,
                'lng': t.lng,
                'elevation': t.elevation,
                'timestamp': t.timestamp.toIso8601String(),
                'speed': t.speedMps,
                'hr': t.heartRate,
                'cadence': t.cadence,
                'accuracy': t.accuracy,
              })
          .toList();
      await _recoveryFile().writeAsString(jsonEncode({
        'distanceM': state.distanceM,
        'elapsedMs': state.elapsedMs,
        'movingTimeMs': state.movingTimeMs,
        'elevationGainM': _elevationGain,
        'points': data,
      }));
    } catch (_) {
      // offline-first: best-effort recovery snapshot
    }
  }

  Future<void> _clearRecovery() async {
    try {
      final f = _recoveryFile();
      if (await f.exists()) await f.delete();
    } catch (e) {
      // Log but don't crash - recovery file may be locked by antivirus/etc.
      // Will be cleaned up on next successful run.
    }
  }

  /// True if a previously interrupted run was found on disk.
  Future<bool> hasRecoverableRun() async {
    try {
      final f = _recoveryFile();
      if (!await f.exists()) return false;
      final raw = await f.readAsString();
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return (j['points'] as List?)?.isNotEmpty ?? false;
    } catch (_) {
      return false;
    }
  }

/// Load an interrupted run from disk and resume it in a `recovering` state.
  Future<void> restoreInterrupted() async {
    try {
      final f = _recoveryFile();
      if (!await f.exists()) return;
      final j = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      final pts = (j['points'] as List)
              .map((e) => TrackPoint(
                    lat: (e['lat'] as num).toDouble(),
                    lng: (e['lng'] as num).toDouble(),
                    elevation: (e['elevation'] as num).toDouble(),
                    timestamp: DateTime.parse(e['timestamp'] as String),
                    speedMps: (e['speed'] as num).toDouble(),
                    heartRate: e['hr'] as int?,
                    cadence: e['cadence'] as int?,
                    accuracy: (e['accuracy'] as num?)?.toInt() ?? 0,
                    state: 'run',
                  ))
              .toList();
      _pts
        ..clear()
        ..addAll(pts);
      _elevationGain = (j['elevationGainM'] as num?)?.toDouble() ?? 0;
      _accumulatedMs = (j['elapsedMs'] as num?)?.toInt() ?? 0;
      _accumulatedMovingMs = (j['movingTimeMs'] as num?)?.toInt() ?? 0;
      state = state.copyWith(
        state: AppEngineState.recovering,
        distanceM: (j['distanceM'] as num?)?.toDouble() ?? 0,
        elapsedMs: (j['elapsedMs'] as num?)?.toInt() ?? 0,
        movingTimeMs: (j['movingTimeMs'] as num?)?.toInt() ?? 0,
        elevationGainM: _elevationGain,
        trackPoints: [..._pts],
      );
    } catch (_) {
      // corrupt snapshot — ignore
    }
  }

  void start() => _enqueue(() => _start());

  Future<void> _start() async {
    // If a previous run was interrupted, continue from where we left off.
    if (await hasRecoverableRun()) {
      await restoreInterrupted();
      if (state.state == AppEngineState.recovering) {
        _engine.resume();
        _sub?.cancel();
        _sub = _engine.startRecording().listen(_onPoint);
        _startTicker();
        // If recovered run had no moving time recorded, start tracking it now
        if (_movingStart == null && _accumulatedMovingMs == 0) {
          _movingStart = DateTime.now();
        }
        state = state.copyWith(state: AppEngineState.recording);
        return;
      }
    }
    _pts.clear();
    _elevationGain = 0;
    _accumulatedMs = 0;
    _accumulatedMovingMs = 0;
    _movingStart = null;
    state = state.copyWith(
      state: AppEngineState.recording,
      distanceM: 0,
      elapsedMs: 0,
      movingTimeMs: 0,
      paceMinPerKm: 0,
      heartRate: null,
      cadence: null,
      elevationGainM: 0,
      calories: 0,
      trackPoints: const [],
    );
    _startTicker();
    _sub?.cancel();
    _sub = _engine.startRecording().listen(_onPoint);
  }

  void _onPoint(TrackPoint p) {
    _pts.add(p);
    final isMoving = p.speedMps > 0.3;
    
    // Track moving time: start timer if speed > 0.3, accumulate when we have speed
    if (isMoving && _movingStart == null) {
      _movingStart = DateTime.now();
    }
    
    if (_pts.length == 1) {
      if (isMoving) {
        _movingStart = DateTime.now();
        state = state.copyWith(
          state: AppEngineState.recording,
          paceMinPerKm: 1000 / (p.speedMps * 60),
          heartRate: p.heartRate,
          cadence: p.cadence,
          elevationGainM: 0,
          calories: 0,
          movingTimeMs: 1000,
          trackPoints: [_pts.first],
        );
      } else {
        state = state.copyWith(
          state: AppEngineState.recording,
          paceMinPerKm: 0.0,
          heartRate: p.heartRate,
          cadence: p.cadence,
          elevationGainM: 0,
          calories: 0,
          movingTimeMs: 0,
          trackPoints: [_pts.first],
        );
      }
      return;
    }
    final prev = _pts[_pts.length - 2];
    final d = _haversine(prev.lat, prev.lng, p.lat, p.lng);
    final gained = (p.elevation - prev.elevation);
    if (gained > 0) _elevationGain += gained;
    final pace = isMoving ? 1000 / (p.speedMps * 60) : 0.0;
    
    // Accumulate moving time if currently moving
    int movingMs = state.movingTimeMs;
    if (isMoving && _movingStart != null) {
      movingMs += 1000; // 1 second per point (rough estimate)
    } else if (!isMoving && _movingStart != null) {
      // When we stop moving, accumulate and reset the moving timer
      movingMs += DateTime.now().difference(_movingStart!).inMilliseconds;
      _movingStart = null;
    }
    
    final calories = (state.elapsedMs / 60000 * 11).round();
    state = state.copyWith(
      state: AppEngineState.recording,
      distanceM: state.distanceM + d,
      paceMinPerKm: pace,
      heartRate: p.heartRate,
      cadence: p.cadence,
      elevationGainM: _elevationGain,
      calories: calories,
      movingTimeMs: movingMs,
      trackPoints: [..._pts],
    );
    // Throttled recovery snapshot (every 10 points keeps the file small).
    if (_pts.length % 10 == 0) _writeRecovery();
  }

  void pause() => _enqueue(() async {
        _engine.pause();
        _stopTicker(isPaused: true);
        await _writeRecovery();
        state = state.copyWith(state: AppEngineState.paused);
      });

  void resume() => _enqueue(() async {
        _engine.resume();
        _startTicker();
        state = state.copyWith(state: AppEngineState.recording);
      });

  Future<void> stop() => _enqueue(() async {
        _sub?.cancel();
        _sub = null;
        _stopTicker();
        await _engine.stop();
        await _clearRecovery();
        state = TrackingState.initial;
      });

  /// Serialise commands so rapid start/stop/pause can never interleave.
  Future<void> _enqueue(Future<void> Function() op) {
    final prev = _lock;
    final completer = Completer<void>();
    _lock = completer.future;
    (prev ?? Future.value()).then((_) async {
      try {
        await op();
      } finally {
        completer.complete();
      }
    });
    return completer.future;
  }
}

final trackingModelProvider = NotifierProvider<TrackingModel, TrackingState>(TrackingModel.new);

double _haversine(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _toRad(double d) => d * pi / 180;
