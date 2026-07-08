import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:mwendo_app/data/maps/offline_map_provider.dart';

const kDarkStyle =
    'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';
const kDefaultCenter = LatLng(-1.2921, 36.8219); // Nairobi

/// Dark-styled MapLibre view that draws a live route polyline from [points].
/// Uses an offline bundle (MBTiles/PMTiles) when one is available, otherwise
/// the online Carto style.
class RouteMap extends ConsumerWidget {
  final List<LatLng> points;
  final String styleString;
  final double zoom;

  const RouteMap({
    super.key,
    required this.points,
    this.styleString = kDarkStyle,
    this.zoom = 14,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineMapProvider).value?.style;
    final style = offline ?? styleString;
    return _RouteMapView(points: points, style: style, zoom: zoom);
  }
}

class _RouteMapView extends StatefulWidget {
  final List<LatLng> points;
  final String style;
  final double zoom;
  const _RouteMapView({
    required this.points,
    required this.style,
    required this.zoom,
  });

  @override
  State<_RouteMapView> createState() => _RouteMapState();
}

class _RouteMapState extends State<_RouteMapView> {
  MapLibreMapController? _ctrl;
  Line? _line;

  @override
  void didUpdateWidget(covariant _RouteMapView old) {
    super.didUpdateWidget(old);
    if (widget.points != old.points) _syncRoute();
  }

  void _syncRoute() {
    final ctrl = _ctrl;
    if (ctrl == null) return;
    // Nothing drawable yet — clear any stale line so only the real route shows.
    if (widget.points.length < 2) {
      if (_line != null) {
        final toRemove = _line!;
        _line = null;
        ctrl.removeLine(toRemove);
      }
      return;
    }
    if (_line != null) ctrl.removeLine(_line!);
    ctrl
        .addLine(
          LineOptions(
            geometry: widget.points,
            lineColor: '#FE2E4B',
            lineWidth: 6,
            lineOpacity: 0.95,
            lineBlur: 0.4,
          ),
        )
        .then((line) => _line = line);
    // Keep the current zoom (don't re-zoom to the default on every rebuild);
    // just recenter on the route's end.
    ctrl.animateCamera(CameraUpdate.newLatLng(widget.points.last));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.length < 2) {
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
              SizedBox(height: 8),
              Text('No route recorded', style: TextStyle(color: Colors.white38)),
            ],
          ),
        ),
      );
    }
    return MapLibreMap(
      initialCameraPosition: CameraPosition(target: widget.points.last, zoom: widget.zoom),
      styleString: widget.style,
      myLocationEnabled: false,
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
