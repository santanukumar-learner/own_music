import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/artist.dart';
import 'models/play_event.dart';
import 'models/recommendation_cache.dart';
import 'models/song.dart';
import 'models/user_rating.dart';

/// Owns the single app-wide [Isar] instance and the list of all five
/// collection schemas.
///
/// Background isolates (the WorkManager tasks in deliverable 5) call
/// [instance] too; Isar returns the already-open instance for the default name
/// within the same isolate, and [Isar.getInstance] short-circuits re-opening.
class IsarService {
  IsarService._();

  static Isar? _isar;

  /// All collection schemas registered with the database. Generated symbols
  /// (`SongSchema`, …) live in the `*.g.dart` part files produced by
  /// `isar_community_generator`.
  static final List<CollectionSchema<dynamic>> schemas = [
    SongSchema,
    PlayEventSchema,
    UserRatingSchema,
    RecommendationCacheSchema,
    ArtistSchema,
  ];

  /// Returns the open Isar instance, opening it on first call. Safe to call
  /// repeatedly.
  static Future<Isar> instance() async {
    final existing = _isar ?? Isar.getInstance();
    if (existing != null && existing.isOpen) {
      return _isar = existing;
    }

    final dir = await getApplicationDocumentsDirectory();
    return _isar = await Isar.open(
      schemas,
      directory: dir.path,
      // The Isar Inspector is dev-only tooling; it is tree-shaken out of
      // release builds regardless, so the default is fine.
    );
  }

  /// Closes the instance. Used in tests and teardown.
  static Future<void> close({bool deleteFromDisk = false}) async {
    await _isar?.close(deleteFromDisk: deleteFromDisk);
    _isar = null;
  }
}
