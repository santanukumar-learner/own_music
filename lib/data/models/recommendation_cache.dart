import 'package:isar_community/isar.dart';

part 'recommendation_cache.g.dart';

/// Cached, ordered recommendation list for a given source song, so repeated
/// `getNextSong` calls are O(1). Invalidated when the model retrains
/// (Task C zeroes these out) or when [isExpired] against [ttlSeconds].
@collection
class RecommendationCache {
  Id id = Isar.autoIncrement;

  /// One cache row per source song.
  @Index(unique: true, replace: true)
  late int sourceSongId;

  /// Ordered candidate song ids (up to 20), best-first.
  List<int> recommendedIds = [];

  late DateTime generatedAt;

  /// Cache lifetime in seconds; the entry is stale once
  /// `now > generatedAt + ttlSeconds`.
  late int ttlSeconds;

  /// Whether this cache entry has passed its TTL.
  @ignore
  bool get isExpired =>
      DateTime.now().difference(generatedAt).inSeconds > ttlSeconds;
}
