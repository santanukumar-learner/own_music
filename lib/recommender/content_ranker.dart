import 'similarity.dart';

/// A candidate song for ranking, carrying just the fields the ranker needs.
class RecCandidate {
  const RecCandidate({
    required this.songId,
    required this.featureVector,
    required this.energy,
    required this.genres,
    this.thumbUp = false,
    this.thumbDown = false,
    this.playedRecently = false,
  });

  final int songId;
  final List<double> featureVector;
  final double energy;
  final List<String> genres;
  final bool thumbUp;
  final bool thumbDown;

  /// Played within the last 2 hours (suppressed per the spec).
  final bool playedRecently;

  String get primaryGenre => genres.isEmpty ? 'Unknown' : genres.first;
}

/// A scored candidate, with the raw content score retained for explainability
/// ("Why this song?" — deliverable 10).
class ScoredSong {
  const ScoredSong({
    required this.songId,
    required this.score,
    required this.contentScore,
    required this.primaryGenre,
  });

  final int songId;
  final double score;
  final double contentScore;
  final String primaryGenre;
}

/// Context for re-ranking: a preferred energy center (time-of-day / mood) and
/// the active mood pin.
class RecContext {
  const RecContext({this.preferredEnergyCenter, this.moodPin});

  final double? preferredEnergyCenter;
  final String? moodPin;
}

const double kThumbUpBoost = 0.15;
const double kEnergyBandBoost = 0.05;
const double kEnergyBand = 0.2;
const double kEnergyPenaltyRate = 0.1;

/// Preferred energy center for the hour of day / active mood pin (Russell energy
/// axis). Returns null when there is no preference.
double? energyCenter({required int hour, String? moodPin}) {
  switch (moodPin) {
    case 'workout':
      return 0.85;
    case 'focus':
      return 0.30;
    case 'chill':
      return 0.35;
  }
  if (hour >= 6 && hour < 12) return 0.75; // morning: upbeat
  if (hour >= 12 && hour < 18) return 0.60; // afternoon
  if (hour >= 18 && hour < 23) return 0.45; // evening
  return 0.30; // late night: calm
}

/// Content-based ranking with context re-ranking, returning candidates sorted
/// best-first. Pure function — all inputs are explicit, so it's unit-testable.
List<ScoredSong> rankContent(
  List<double> queryVector,
  List<RecCandidate> candidates,
  RecContext context,
) {
  final scored = <ScoredSong>[];
  for (final c in candidates) {
    final content = cosineUnit(queryVector, c.featureVector); // 0..1
    var score = content;

    final center = context.preferredEnergyCenter;
    if (center != null) {
      final dist = (c.energy - center).abs();
      score += dist <= kEnergyBand
          ? kEnergyBandBoost
          : -kEnergyPenaltyRate * (dist - kEnergyBand);
    }

    if (c.thumbUp) score += kThumbUpBoost;
    if (c.thumbDown) score = 0.0; // never play
    if (c.playedRecently) score = 0.0; // suppress last 2h

    scored.add(ScoredSong(
      songId: c.songId,
      // Clamp only the lower bound: thumb-down / recency force 0, but boosts may
      // legitimately push the ranking score above 1 (content stays 0..1).
      score: score < 0.0 ? 0.0 : score,
      contentScore: content,
      primaryGenre: c.primaryGenre,
    ));
  }

  scored.sort((a, b) => b.score.compareTo(a.score));
  return _injectGenreDiversity(scored);
}

/// If the top [topN] candidates all share one genre, pull the [inject] best
/// different-genre candidates into the lower end of that window.
List<ScoredSong> _injectGenreDiversity(
  List<ScoredSong> sorted, {
  int topN = 10,
  int inject = 2,
}) {
  if (sorted.length <= topN) return sorted;

  final top = sorted.take(topN).toList();
  if (top.map((s) => s.primaryGenre).toSet().length > 1) {
    return sorted; // already diverse
  }
  final dominant = top.first.primaryGenre;
  final different = sorted
      .skip(topN)
      .where((s) => s.primaryGenre != dominant && s.score > 0)
      .take(inject)
      .toList();
  if (different.isEmpty) return sorted;

  final result = List<ScoredSong>.from(sorted);
  for (var i = 0; i < different.length; i++) {
    final pick = different[i];
    result.remove(pick);
    final insertAt = (topN - inject + i).clamp(0, result.length);
    result.insert(insertAt, pick);
  }
  return result;
}
