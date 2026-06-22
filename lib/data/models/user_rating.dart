import 'package:isar_community/isar.dart';

part 'user_rating.g.dart';

/// Explicit thumbs up / down for a song. Exactly one row per song (the unique
/// index upserts on update). Feeds the recommender immediately: thumbed-up
/// tracks get a score boost, thumbed-down tracks are never played.
@collection
class UserRating {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late int songId;

  /// `true` when thumbed up; `null` if never set / cleared.
  bool? thumbUp;

  /// `true` when thumbed down; `null` if never set / cleared.
  bool? thumbDown;

  late DateTime updatedAt;
}
