import 'package:isar_community/isar.dart';

part 'play_event.g.dart';

/// One playback session of a song. These rows are the implicit-feedback signal
/// for the ALS collaborative model (Task C) and drive context re-ranking
/// (e.g. suppressing tracks played in the last 2 hours).
@collection
class PlayEvent {
  Id id = Isar.autoIncrement;

  @Index()
  late int songId;

  /// Indexed for "played in the last 2 hours" suppression and recency queries.
  @Index()
  late DateTime startedAt;

  /// Fraction of the track actually played, 0.0–1.0.
  late double completionRate;

  late bool skipped;

  /// autoplay | manual | queue — see `PlayContext`.
  late String context;

  /// The explicit mood filter active when the song played, if any —
  /// see `MoodPin`.
  String? moodPin;
}
