import 'package:isar_community/isar.dart';

import 'isar_service.dart';
import 'models/play_event.dart';

/// Records playback events and answers recency queries used by the recommender
/// (last-2h suppression) and, later, the ALS collaborative model.
class PlayEventRepository {
  PlayEventRepository(this._isar);

  final Isar _isar;

  static Future<PlayEventRepository> open() async =>
      PlayEventRepository(await IsarService.instance());

  Future<void> record({
    required int songId,
    required String context,
    String? moodPin,
    double completionRate = 0.0,
    bool skipped = false,
  }) {
    final event = PlayEvent()
      ..songId = songId
      ..startedAt = DateTime.now()
      ..completionRate = completionRate
      ..skipped = skipped
      ..context = context
      ..moodPin = moodPin;
    return _isar.writeTxn(() => _isar.playEvents.put(event));
  }

  /// Ids of songs started at or after [since].
  Future<Set<int>> songIdsPlayedSince(DateTime since) async {
    final events =
        await _isar.playEvents.filter().startedAtGreaterThan(since).findAll();
    return events.map((e) => e.songId).toSet();
  }

  Future<int> count() => _isar.playEvents.count();
}
