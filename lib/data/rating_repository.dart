import 'package:isar_community/isar.dart';

import 'isar_service.dart';
import 'models/user_rating.dart';

/// Thumbs up/down per song (one row per song). Feeds the recommender's
/// boost/never-play rules.
class RatingRepository {
  RatingRepository(this._isar);

  final Isar _isar;

  static Future<RatingRepository> open() async =>
      RatingRepository(await IsarService.instance());

  Future<void> setThumb({required int songId, bool? up, bool? down}) {
    return _isar.writeTxn(() async {
      final existing =
          await _isar.userRatings.filter().songIdEqualTo(songId).findFirst();
      final rating = existing ?? (UserRating()..songId = songId);
      rating
        ..thumbUp = up
        ..thumbDown = down
        ..updatedAt = DateTime.now();
      await _isar.userRatings.put(rating);
    });
  }

  Future<UserRating?> forSong(int songId) =>
      _isar.userRatings.filter().songIdEqualTo(songId).findFirst();

  Future<Map<int, UserRating>> all() async {
    final list = await _isar.userRatings.where().findAll();
    return {for (final r in list) r.songId: r};
  }
}
