import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Free, key-less, globally-available Carto dark basemap. Works everywhere
/// (including Kenya) with no API key. This is the single style the app ships
/// with — the offline tile server was removed in favour of MapLibre's built-in
/// offline regions API as a future, standalone feature.
const kDarkStyle =
    'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

/// Default map centre (Nairobi) used before the first GPS fix arrives.
const kDefaultCenter = LatLng(-1.2921, 36.8219);

const _kRouteColor = '#FE2E4B';
const _kRouteWidth = 6.0;
const _kRouteOpacity = 0.95;
const _kRouteBlur = 0.5;

/// How the [MwendoMap] behaves.
///
/// * [live] — follows the runner during an active recording, draws the
///   breadcrumb trail as points stream in, and shows a re-center button when
///   the user pans away.
/// * [replay] — a static view of a finished route. The camera is set once and
///   never moves; the polyline is (re)drawn whenever [MwendoMap.points]
///   changes (e.g. when an activity loads asynchronously).
enum MapMode { live, replay }

/// A single MapLibre GL map used by both the live tracking screen and the
/// post-run activity detail screen. Consolidating the two former
/// implementations (`_MapView` and `RouteMap`) keeps their drawing/camera
/// logic identical and prevents the two from drifting apart with divergent
/// bugs.
class MwendoMap extends StatefulWidget {
  /// Route vertices, ordered oldest → newest.
  final List<LatLng> points;

  /// Whether the map follows the user (live) or shows a static route (replay).
  final MapMode mode;

  /// Initial zoom for replay maps. Live maps zoom in on the first GPS fix.
  final double zoom;

  /// Show the native "blue dot" user-location marker. Requires location
  /// permission to have been granted by the caller.
  final bool locationEnabled;

  /// True while a run is actively recording. When true the live map hands the
  /// camera to MapLibre's native tracking so there are no manual camera
  /// animations mid-run.
  final bool isRecording;

  /// MapLibre style JSON URL. Defaults to the online Carto dark style.
  final String styleString;

  const MwendoMap({
    super.key,
    required this.points,
    this.mode = MapMode.replay,
    this.zoom = 14,
    this.locationEnabled = false,
    this.isRecording = false,
    this.styleString = kDarkStyle,
  });

  @override
  State<MwendoMap> createState() => _MwendoMapState();
}

class _MwendoMapState extends State<MwendoMap> {
  MapLibreMapController? _ctrl;
  Line? _line;

  // Serialise route draws so overlapping GPS ticks never race on the same
  // line id. A pending draw coalesces to the most recent coordinates.
  bool _isSyncing = false;
  List<LatLng>? _pendingCoords;

  // Live-only camera state.
  bool _autoFollow = true;
  bool _firstFixDone = false;
  // True once the remote style (and its sprite/glyphs/tiles) has loaded.
  bool _styleLoaded = false;

  bool get _isLive => widget.mode == MapMode.live;

  @override
  void didUpdateWidget(covariant MwendoMap old) {
    super.didUpdateWidget(old);
    // A run stop clears the points (length shrinks); reset follow state so the
    // next run re-centers instead of inheriting a panned-away _autoFollow=false.
    if (old.points.length > widget.points.length) {
      _autoFollow = true;
      _firstFixDone = false;
    }
    // Detect new data by length. Live points only ever grow; replay points go
    // from empty to a full route once the activity loads. Either way a length
    // change means we must redraw — the previous RouteMap had no
    // didUpdateWidget at all and so never drew asynchronously-loaded routes.
    if (widget.points.length != old.points.length) {
      if (_isLive && !_firstFixDone && widget.points.isNotEmpty) {
        _firstFixDone = true;
        _autoFollow = true;
        _ctrl?.animateCamera(
          CameraUpdate.newLatLngZoom(widget.points.first, 16),
        );
      }
      _syncRoute();
    }
  }

  void _syncRoute() {
    final ctrl = _ctrl;
    if (ctrl == null) return;
    // Nothing drawable yet — drop any stale line so the map only ever shows a
    // route the user actually recorded.
    if (widget.points.length < 2) {
      _clearLine();
      return;
    }
    final coords = List<LatLng>.from(widget.points);

    if (_isSyncing) {
      _pendingCoords = coords;
      return;
    }

    _isSyncing = true;
    _drawRoute(coords).whenComplete(() {
      _isSyncing = false;
      if (!mounted) return;
      final pending = _pendingCoords;
      if (pending != null) {
        _pendingCoords = null;
        _syncRoute();
      }
    });
  }

  Future<void> _clearLine() async {
    final ctrl = _ctrl;
    if (ctrl == null || _line == null) return;
    final toRemove = _line!;
    _line = null;
    try {
      await ctrl.removeLine(toRemove);
    } catch (_) {
      // Controller may be mid-dispose; ignore.
    }
  }

  Future<void> _drawRoute(List<LatLng> coords) async {
    final ctrl = _ctrl;
    if (ctrl == null || coords.length < 2) return;

    // Update the line geometry in place rather than remove+add on every tick
    // (the old RouteMap remove+add caused a flicker and orphaned lines).
    if (_line != null) {
      try {
        await ctrl.updateLine(_line!, LineOptions(geometry: coords));
      } catch (_) {
        // updateLine can fail before the engine has indexed the line; fall
        // back to remove+add. Bail out if the widget/controller died meanwhile.
        if (!mounted || _ctrl == null) return;
        try {
          await ctrl.removeLine(_line!);
        } catch (_) {}
        if (!mounted || _ctrl == null) return;
        _line = await ctrl.addLine(_routeOptions(coords));
      }
    } else {
      _line = await ctrl.addLine(_routeOptions(coords));
    }

    // Guard against completion after disposal.
    if (!mounted || _ctrl == null) return;

    // Replay maps are static — the camera is set once via initialCameraPosition
    // and never moves. Live maps rely on native tracking mode while recording;
    // in the idle (non-recording) live case we gently recenter on the latest
    // point while the user is still following.
    if (_isLive && _autoFollow && !widget.isRecording) {
      await ctrl.animateCamera(CameraUpdate.newLatLng(coords.last));
    }
  }

  LineOptions _routeOptions(List<LatLng> coords) => LineOptions(
        geometry: coords,
        lineColor: _kRouteColor,
        lineWidth: _kRouteWidth,
        lineOpacity: _kRouteOpacity,
        lineBlur: _kRouteBlur,
      );

  MyLocationTrackingMode get _trackingMode {
    if (!_isLive || !_autoFollow) return MyLocationTrackingMode.none;
    // North-up follow while a run is live. We deliberately avoid
    // `trackingCompass`: it spins the camera to the user's heading on every
    // fix and fights user pinch-zoom (Bugs C1/Z1). Plain `tracking` still lets
    // the user pinch-zoom (which dismisses follow) and pan (which sets
    // `_autoFollow = false` via onCameraTrackingDismissed).
    return MyLocationTrackingMode.tracking;
  }

  void _recenter() {
    setState(() => _autoFollow = true);
    final ctrl = _ctrl;
    if (ctrl != null && widget.points.isNotEmpty) {
      ctrl.animateCamera(CameraUpdate.newLatLng(widget.points.last));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Replay maps with no usable route show a friendly placeholder instead of
    // an empty grey map.
    if (!_isLive && widget.points.length < 2) {
      return _EmptyRoutePlaceholder();
    }

    final initialTarget =
        widget.points.isNotEmpty ? widget.points.last : kDefaultCenter;

    final map = MapLibreMap(
      // Keep the key stable: MapLibre GL cannot hot-swap the style URL, and a
      // changing key destroys the widget along with the drawn route and camera.
      key: const ValueKey('mwendo-map'),
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: _isLive ? 12 : widget.zoom,
      ),
      styleString: widget.styleString,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      },
      myLocationEnabled: widget.locationEnabled,
      myLocationTrackingMode: _trackingMode,
      onMapCreated: (c) {
        _ctrl = c;
      },
      onStyleLoadedCallback: () {
        // Annotations must be (re)added after the style has loaded; a style
        // (re)load also drops any previously-added line.
        _line = null;
        _syncRoute();
        if (!_styleLoaded) {
          _styleLoaded = true;
          if (mounted) setState(() {});
        }
      },
      onCameraTrackingDismissed: () {
        // Fires only on a real user pan/zoom, never on programmatic
        // camera moves. Let the user explore without snapping back.
        if (mounted) setState(() => _autoFollow = false);
      },
      onUserLocationUpdated: _isLive
          ? (userLocation) {
              // Zoom to the very first GPS fix even before any route point is
              // recorded, so the blue dot is immediately visible.
              if (_ctrl != null && !_firstFixDone) {
                _firstFixDone = true;
                _ctrl!.animateCamera(
                  CameraUpdate.newLatLngZoom(userLocation.position, 16),
                );
              }
            }
          : null,
    );

    // Overlay zoom controls (explicit manual zoom — Bug Z1) on every mode, plus
    // a re-center button on the live map once the user has panned away, and a
    // spinner while the remote style is still loading (perceived slow load).
    return Stack(
      children: [
        map,
        if (!_styleLoaded)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
        Positioned(
          right: AppTheme.s16,
          bottom: (_isLive && !_autoFollow) ? 72 : AppTheme.s16,
          child: _ZoomControls(
            onIn: () => _ctrl?.animateCamera(CameraUpdate.zoomIn()),
            onOut: () => _ctrl?.animateCamera(CameraUpdate.zoomOut()),
          ),
        ),
        if (_isLive && !_autoFollow)
          Positioned(
            right: AppTheme.s16,
            bottom: AppTheme.s16,
            child: _RecenterButton(onTap: _recenter),
          ),
      ],
    );
  }
}

/// Floating action button that re-enables camera follow on the live map.
class _RecenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RecenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Re-center map',
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

/// +/- buttons giving a first-class manual zoom affordance (Bug Z1). Works
/// regardless of the active tracking mode, unlike pinch-zoom which also
/// dismisses camera follow.
class _ZoomControls extends StatelessWidget {
  final VoidCallback onIn;
  final VoidCallback onOut;
  const _ZoomControls({required this.onIn, required this.onOut});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ZoomButton(icon: Icons.add_rounded, onTap: onIn),
        const SizedBox(height: AppTheme.s8),
        _ZoomButton(icon: Icons.remove_rounded, onTap: onOut),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Zoom',
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Shown by replay maps when there is no route to draw.
class _EmptyRoutePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.2, -0.3),
          radius: 1.4,
          colors: [Color(0xFF1B2733), Color(0xFF0B0B0C)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined, size: 40, color: Colors.white24),
            SizedBox(height: AppTheme.s8),
            Text('No route recorded', style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}
