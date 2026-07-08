import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gamification/leaderboard_data.dart';
import '../../core/network/api_client.dart';

/// Remote leaderboard entry shape (mirrors backend `leaderboard.Entry`).
class RemoteEntry {
  final String userId;
  final double score;
  final int rank;
  const RemoteEntry({required this.userId, required this.score, required this.rank});

  factory RemoteEntry.fromJson(Map<String, dynamic> j) => RemoteEntry(
        userId: j['user_id'] ?? '',
        score: (j['score'] ?? 0).toDouble(),
        rank: j['rank'] ?? 0,
      );
}

/// Fetches the leaderboard from the backend and merges the local user in,
/// falling back to the static board when the API is unreachable. This closes
/// the "backend is never called" gap flagged in the audit.
final remoteLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, int>((ref, userXp) async {
  try {
    final client = ref.watch(apiClientProvider);
    final res = await client.dio.get('/api/v1/leaderboard');
    final list = (res.data as List)
        .map((e) => RemoteEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    final remote = list
        .map((e) => LeaderboardEntry(
              name: e.userId,
              xp: e.score.round(),
              flag: '🏃',
            ))
        .toList();
    final merged = [
      ...remote,
      LeaderboardEntry(name: 'You', xp: userXp, flag: '📍', you: true),
    ];
    merged.sort((a, b) => b.xp.compareTo(a.xp));
    return merged;
  } catch (_) {
    // offline-first: keep the app usable without a backend.
    return leaderboardWithUser(userXp);
  }
});
