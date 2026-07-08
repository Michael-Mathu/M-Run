import 'dart:convert';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mwendo_app/data/models/run_record.dart';

/// Serialise a [RunRecord] to a GPX 1.1 track file.
String gpxFromRunRecord(RunRecord r) {
  final pts = StringBuffer();
  for (int i = 0; i < r.route.length; i++) {
    final p = r.route[i];
    final ele = i < r.elevation.length ? r.elevation[i] : 0.0;
    pts.writeln('      <trkpt lat="${p.latitude}" lon="${p.longitude}">'
        '<ele>$ele</ele></trkpt>');
  }
  final start = r.startedAt.toUtc().toIso8601String();
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Mwendo" xmlns="http://www.topografix.com/GPX/1/1">
  <metadata>
    <name>${_escape(r.type)}</name>
    <time>$start</time>
  </metadata>
  <trk>
    <name>${_escape(r.type)}</name>
    <trkseg>
$pts
    </trkseg>
  </trk>
</gpx>
''';
}

/// Serialise several [RunRecord]s to a single JSON document.
String jsonFromRuns(List<RunRecord> runs) =>
    jsonEncode(runs.map((r) => r.toJson()).toList());

String _escape(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// Decode a GPX track string into a list of lat/lng points (best-effort).
List<LatLng> pointsFromGpx(String gpx) {
  final out = <LatLng>[];
  final regex = RegExp(r'<trkpt[^>]*lat="([-\d.]+)"[^>]*lon="([-\d.]+)"');
  for (final m in regex.allMatches(gpx)) {
    final lat = double.tryParse(m.group(1)!);
    final lng = double.tryParse(m.group(2)!);
    if (lat != null && lng != null) out.add(LatLng(lat, lng));
  }
  return out;
}
