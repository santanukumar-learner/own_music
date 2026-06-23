import '../data/isar_service.dart';
import '../data/models/song.dart';
import '../data/play_event_repository.dart';
import '../data/rating_repository.dart';
import '../data/song_repository.dart';
import 'content_ranker.dart';

/// A chosen next song plus the data needed for the "Why this song?" sheet.
class Recommendation {
  const Recommendation({
    required this.song,
    required this.score,
    required this.contentScore,
    required this.reason,
  });

  final Song song;
  final double score;
  final double contentScore;
  final String reason;
}

/// The content-based `getNextSong` (deliverable 8, content path). The
/// collaborative ALS blend (deliverable 7) layers on once play history exists.
class RecommenderService {
  RecommenderService(this._songs, this._events, this._ratings);

  final SongRepository _songs;
  final PlayEventRepository _events;
  final RatingRepository _ratings;

  static Future<RecommenderService> open() async {
    final isar = await IsarService.instance();
    return RecommenderService(
      SongRepository(isar),
      PlayEventRepository(isar),
      RatingRepository(isar),
    );
  }

  /// Best next song after [currentSongId], or null if it can't recommend yet
  /// (current song not enriched, or no other enriched candidates).
  Future<Recommendation?> nextAfter(
    int currentSongId, {
    String? moodPin,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    final current = await _songs.byId(currentSongId);
    if (current == null || current.featureVector.isEmpty) return null;

    final candidates = await _songs.recommendable();
    final ratings = await _ratings.all();
    final recent = await _events
        .songIdsPlayedSince(clock.subtract(const Duration(hours: 2)));

    final byId = <int, Song>{};
    final recCandidates = <RecCandidate>[];
    for (final s in candidates) {
      if (s.id == currentSongId || s.featureVector.isEmpty) continue;
      byId[s.id] = s;
      final r = ratings[s.id];
      recCandidates.add(RecCandidate(
        songId: s.id,
        featureVector: s.featureVector,
        energy: s.energy,
        genres: s.genres,
        thumbUp: r?.thumbUp ?? false,
        thumbDown: r?.thumbDown ?? false,
        playedRecently: recent.contains(s.id),
      ));
    }
    if (recCandidates.isEmpty) return null;

    final ctx = RecContext(
      preferredEnergyCenter: energyCenter(hour: clock.hour, moodPin: moodPin),
      moodPin: moodPin,
    );
    final ranked = rankContent(current.featureVector, recCandidates, ctx);

    // Prefer the best with a positive score (not suppressed); fall back to top.
    final best = ranked.firstWhere(
      (s) => s.score > 0,
      orElse: () => ranked.first,
    );
    final song = byId[best.songId];
    if (song == null) return null;

    return Recommendation(
      song: song,
      score: best.score,
      contentScore: best.contentScore,
      reason: _explain(current, song, best),
    );
  }

  String _explain(Song from, Song to, ScoredSong scored) {
    final pct = (scored.contentScore * 100).round();
    final parts = <String>['$pct% match'];
    final fromGenre = from.genres.isNotEmpty ? from.genres.first : null;
    final toGenre = to.genres.isNotEmpty ? to.genres.first : null;
    if (toGenre != null && toGenre == fromGenre) {
      parts.add('same genre · $toGenre');
    } else if (toGenre != null && toGenre != 'Unknown') {
      parts.add(toGenre);
    }
    parts.add('${to.mood} mood');
    final ref = from.title ?? from.fileName;
    return '${parts.join(' · ')}  ·  similar to "$ref"';
  }
}
