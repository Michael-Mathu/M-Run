import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// A single decoded tile plus the MIME type MapLibre should treat it as.
class TileResult {
  final Uint8List bytes;
  final String contentType;
  const TileResult(this.bytes, this.contentType);
}

/// Source of map tiles that works fully offline (no network).
abstract class TileProvider {
  int get minZoom;
  int get maxZoom;

  /// Returns the tile bytes for the given XYZ coordinate, or `null` when the
  /// bundle does not contain that tile.
  Future<TileResult?> getTile(int z, int x, int y);

  void dispose();
}

/// Opens an [MBTiles](https://github.com/mapbox/mbtiles-spec) SQLite archive
/// and serves its raster tiles. MBTiles uses TMS row ordering (y from the
/// bottom), so we flip the y axis to the XYZ scheme MapLibre expects.
class MbTilesBundle implements TileProvider {
  MbTilesBundle(this.path) {
    _db = sqlite3.open(path);
    final meta = _db.select('SELECT name, value FROM metadata');
    final map = {for (final r in meta) r['name'] as String: r['value'] as String};
    minZoom = int.tryParse(map['minzoom'] ?? '') ?? 0;
    maxZoom = int.tryParse(map['maxzoom'] ?? '') ?? 18;
    _format = map['format'] == 'jpg' || map['format'] == 'jpeg'
        ? 'image/jpeg'
        : 'image/png';
  }

  final String path;
  late final Database _db;
  late final String _format;

  @override
  late final int minZoom;

  @override
  late final int maxZoom;

  @override
  Future<TileResult?> getTile(int z, int x, int y) async {
    if (z < minZoom || z > maxZoom) return null;
    // TMS -> XYZ flip.
    final tmsY = (1 << z) - 1 - y;
    final rows = _db.select(
      'SELECT tile_data FROM tiles '
      'WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?',
      [z, x, tmsY],
    );
    if (rows.isEmpty) return null;
    final data = rows.first['tile_data'];
    if (data == null) return null;
    final bytes = data is Uint8List ? data : Uint8List.fromList(data as List<int>);
    return TileResult(bytes, _format);
  }

  @override
  void dispose() => _db.close();
}

/// PMTiles v3 archive reader. The 127-byte header points at a root directory
/// (and optional leaf directories); entries are addressed by a composite
/// Hilbert [TileID]. See https://github.com/protomaps/PMTiles/blob/main/spec/v3/spec.md
class PmTilesBundle implements TileProvider {
  PmTilesBundle(this.path) {
    _raf = File(path).openSync();
    _readHeader();
  }

  final String path;
  late final RandomAccessFile _raf;

  // Header fields actually used for tile lookup.
  late int _rootDirOffset;
  late int _rootDirLength;
  late int _leafDirOffset;
  late int _tileDataOffset;
  late int _internalCompression;
  late int _tileCompression;
  late int _tileType;

  @override
  late final int minZoom;

  @override
  late final int maxZoom;

  Uint8List _readAt(int position, int length) {
    _raf.setPositionSync(position);
    return _raf.readSync(length);
  }

  void _readHeader() {
    final header = _readAt(0, 127);
    const magic = [0x50, 0x4D, 0x54, 0x69, 0x6C, 0x65, 0x73];
    for (var i = 0; i < magic.length; i++) {
      if (header[i] != magic[i]) {
        throw const FormatException('Not a PMTiles v3 archive');
      }
    }
    if (header[7] != 3) {
      throw const FormatException('Unsupported PMTiles version');
    }
    _rootDirOffset = _u64(header, 8);
    _rootDirLength = _u64(header, 16);
    _leafDirOffset = _u64(header, 40);
    _tileDataOffset = _u64(header, 56);
    _internalCompression = header[97];
    _tileCompression = header[98];
    _tileType = header[99];
    minZoom = header[100];
    maxZoom = header[101];
  }

  static int _u64(Uint8List b, int offset) {
    var value = 0;
    for (var i = 7; i >= 0; i--) {
      value = (value << 8) | b[offset + i];
    }
    return value;
  }

  @override
  Future<TileResult?> getTile(int z, int x, int y) async {
    if (z < minZoom || z > maxZoom) return null;
    final tileId = _zxyToTileId(z, x, y);

    final root = _decodeDir(_decompress(
      _readAt(_rootDirOffset, _rootDirLength),
      _internalCompression,
    ));
    var entry = _findEntry(root, tileId);
    if (entry == null) return null;

    if (entry.runLength == 0) {
      // Points at a leaf directory; descend into it.
      final leafBytes = _readAt(_leafDirOffset + entry.offset, entry.length);
      final leafEntries = _decodeDir(_decompress(leafBytes, _internalCompression));
      final leafEntry = _findEntry(leafEntries, tileId);
      if (leafEntry == null || leafEntry.runLength == 0) return null;
      entry = leafEntry;
    }

    final raw = _readAt(_tileDataOffset + entry.offset, entry.length);
    final bytes = _decompress(raw, _tileCompression);
    return TileResult(bytes, _contentTypeFor(_tileType));
  }

  /// Composite Hilbert TileID for a Z/X/Y coordinate (PMTiles v3).
  static int _zxyToTileId(int z, int x, int y) {
    var acc = 0;
    for (var i = 0; i < z; i++) {
      final shift = z - i - 1;
      final rx = (x >> shift) & 1;
      final ry = (y >> shift) & 1;
      acc += ((3 * rx) ^ ry) << (2 * (z - i - 1));
    }
    return acc + ((1 << (2 * z)) - 1) ~/ 3;
  }

  /// Last entry whose TileID is <= [tileId]; a tile entry also matches when
  /// [tileId] falls within its run length.
  static _DirEntry? _findEntry(List<_DirEntry> entries, int tileId) {
    var lo = 0;
    var hi = entries.length - 1;
    var idx = -1;
    while (lo <= hi) {
      final mid = (lo + hi) ~/ 2;
      if (entries[mid].tileId <= tileId) {
        idx = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    if (idx < 0) return null;
    final e = entries[idx];
    if (e.runLength == 0) return e; // leaf directory entry
    if (tileId <= e.tileId + e.runLength) return e;
    return null;
  }

  /// Reads directory entries (PMTiles v3 encoding: count, then TileIDs,
  /// run lengths, lengths and offsets, all as LEB128 varints).
  static List<_DirEntry> _decodeDir(Uint8List data) {
    var i = 0;
    int readVarint() {
      var result = 0;
      var shift = 0;
      while (true) {
        final byte = data[i++];
        result |= (byte & 0x7F) << shift;
        if ((byte & 0x80) == 0) break;
        shift += 7;
      }
      return result;
    }

    final num = readVarint();
    final tileIds = List.generate(num, (_) => readVarint());
    final runLengths = List.generate(num, (_) => readVarint());
    final lengths = List.generate(num, (_) => readVarint());
    final offsets = List.generate(num, (_) => readVarint());

    final entries = <_DirEntry>[];
    var lastId = 0;
    for (var k = 0; k < num; k++) {
      lastId += tileIds[k];
      final offset = offsets[k] == 0 && k > 0
          ? entries[k - 1].offset + entries[k - 1].length
          : offsets[k] - 1;
      entries.add(_DirEntry(lastId, offset, lengths[k], runLengths[k]));
    }
    return entries;
  }

  static Uint8List _decompress(Uint8List bytes, int compression) {
    switch (compression) {
      case 1: // None
        return bytes;
      case 2: // gzip
        return gzip.decode(bytes) as Uint8List;
      case 3: // brotli
      case 4: // zstd
        // ponytail: no stdlib decoder; add `brotli`/`zstd` package if bundles
        // use these codecs. None/gzip cover the common raster basemap case.
        throw UnsupportedError(
          'PMTiles compression $compression is not supported',
        );
      default:
        throw UnsupportedError('Unknown PMTiles compression $compression');
    }
  }

  static String _contentTypeFor(int tileType) {
    switch (tileType) {
      case 1:
        return 'application/x-protobuf'; // MVT vector tile
      case 2:
        return 'image/png';
      case 3:
        return 'image/jpeg';
      case 4:
        return 'image/webp';
      case 5:
        return 'image/avif';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  void dispose() => _raf.closeSync();
}

class _DirEntry {
  const _DirEntry(this.tileId, this.offset, this.length, this.runLength);
  final int tileId;
  final int offset;
  final int length;
  final int runLength;
}

/// Serves tiles from a [TileProvider] over a loopback HTTP server so MapLibre
/// can consume them through a normal raster source URL — fully offline.
class OfflineTileServer {
  OfflineTileServer._(this.provider, this._server, this.port);

  final TileProvider provider;
  final HttpServer _server;
  final int port;

  /// `/{z}/{x}/{y}.png` template MapLibre uses as a raster source.
  String get styleTemplate => 'http://127.0.0.1:$port/{z}/{x}/{y}.png';

  static Future<OfflineTileServer> start(TileProvider provider) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final s = OfflineTileServer._(provider, server, server.port);
    server.listen(s._handle);
    return s;
  }

  Future<void> _handle(HttpRequest req) async {
    final m = RegExp(r'^/(\d+)/(\d+)/(\d+)\.(?:png|jpg|jpeg|webp|pbf)$')
        .firstMatch(req.uri.path);
    if (m == null) {
      req.response.statusCode = 404;
      await req.response.close();
      return;
    }
    final z = int.parse(m.group(1)!);
    final x = int.parse(m.group(2)!);
    final y = int.parse(m.group(3)!);
    try {
      final tile = await provider.getTile(z, x, y);
      if (tile == null) {
        req.response.statusCode = 204; // no content
        await req.response.close();
        return;
      }
      req.response.headers.contentType = ContentType.parse(tile.contentType);
      req.response.add(tile.bytes);
      await req.response.close();
    } catch (e) {
      req.response.statusCode = 500;
      await req.response.close();
    }
  }

  void dispose() {
    _server.close(force: true);
    provider.dispose();
  }
}

/// Locates an offline map bundle in `<docs>/offline_maps`, starts a tile
/// server for it, and exposes a ready-to-use MapLibre style JSON. When no
/// bundle is present, [style] stays `null` and callers should fall back to an
/// online style.
class OfflineMapController {
  OfflineMapController._(this.provider, this.server);

  final TileProvider provider;
  final OfflineTileServer server;

  String get style =>
      _style(server.styleTemplate, provider.minZoom, provider.maxZoom);

  static Future<OfflineMapController> init() async {
    final file = await _findBundle();
    if (file == null) {
      throw StateError('No offline map bundle found in offline_maps/');
    }
    final provider = file.path.endsWith('.pmtiles')
        ? PmTilesBundle(file.path)
        : MbTilesBundle(file.path);
    final server = await OfflineTileServer.start(provider);
    return OfflineMapController._(provider, server);
  }

  static Future<File?> _findBundle() async {
    final dir = await getApplicationDocumentsDirectory();
    final mapsDir = Directory(p.join(dir.path, 'offline_maps'));
    if (!await mapsDir.exists()) return null;
    final files = await mapsDir
        .list()
        .where((e) => e is File)
        .cast<File>()
        .where((f) =>
            f.path.endsWith('.mbtiles') || f.path.endsWith('.pmtiles'))
        .toList();
    if (files.isEmpty) return null;
    files.sort((a, b) => a.path.compareTo(b.path));
    return files.first;
  }

  static String _style(String urlTemplate, int minZoom, int maxZoom) =>
      jsonEncode({
        'version': 8,
        'sources': {
          'offline': {
            'type': 'raster',
            'tiles': [urlTemplate],
            'tileSize': 256,
            'minzoom': minZoom,
            'maxzoom': maxZoom,
          }
        },
        'layers': [
          {
            'id': 'offline-layer',
            'type': 'raster',
            'source': 'offline',
          }
        ],
      });

  void dispose() => server.dispose();
}

enum MapSource { online, offline }

class MapSourceNotifier extends Notifier<MapSource> {
  @override
  MapSource build() => MapSource.offline;

  void toggle() {
    state = state == MapSource.offline ? MapSource.online : MapSource.offline;
  }
}

final mapSourceProvider = NotifierProvider<MapSourceNotifier, MapSource>(MapSourceNotifier.new);

/// Loads an offline map bundle once for the app's lifetime and caches the
/// resulting tile server. Resolves to `null` when no bundle is present, so
/// callers can fall back to an online style.
final offlineMapProvider = FutureProvider<OfflineMapController?>((ref) async {
  try {
    final controller = await OfflineMapController.init();
    ref.onDispose(() {
      controller.dispose();
    });
    return controller;
  } catch (_) {
    return null;
  }
});
