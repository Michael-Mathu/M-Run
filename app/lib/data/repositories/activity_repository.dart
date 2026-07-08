import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/run_record.dart';

/// Append-only, offline-first store for completed runs. The audit flagged that
/// real runs were discarded after updating XP; this persists them so the
/// activity list/detail show actual history.
class ActivityRepository {
  final File _file;

  ActivityRepository(this._file);

  Future<List<RunRecord>> list() async {
    try {
      if (!await _file.exists()) return const [];
      final raw = await _file.readAsString();
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final runs = list.map(RunRecord.fromJson).toList();
      runs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return runs;
    } catch (_) {
      return const [];
    }
  }

  Future<RunRecord?> get(String id) async {
    final all = await list();
    try {
      return all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(RunRecord record) async {
    final all = await list();
    all.removeWhere((r) => r.id == record.id);
    all.add(record);
    await _file.writeAsString(
      jsonEncode(all.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> delete(String id) async {
    final all = await list()..removeWhere((r) => r.id == id);
    await _file.writeAsString(
      jsonEncode(all.map((r) => r.toJson()).toList()),
    );
  }
}

/// Resolves the on-disk [ActivityRepository] once (path_provider is async).
final activityRepositoryProvider = FutureProvider<ActivityRepository>((ref) async {
  // ponytail: a JSON file is the simplest correct local store; swap for Drift
  // when the generated layer is wired (tables.dart already declares columns).
  final dir = await getApplicationDocumentsDirectory();
  return ActivityRepository(File(p.join(dir.path, 'activities.json')));
});

/// Live list of runs (most recent first).
final activitiesProvider = FutureProvider<List<RunRecord>>((ref) async {
  final repo = await ref.watch(activityRepositoryProvider.future);
  return repo.list();
});

/// Looks up a single run by id (real history; null for sample activities).
final activityByIdProvider =
    FutureProvider.family<RunRecord?, String>((ref, id) async {
  final repo = await ref.watch(activityRepositoryProvider.future);
  return repo.get(id);
});
