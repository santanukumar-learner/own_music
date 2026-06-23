import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../data/play_event_repository.dart';
import '../data/song_repository.dart';
import '../library/songs_provider.dart';
import '../recommender/recommender_service.dart';

/// The single shared just_audio player for the app.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// The song currently loaded into the player (or null when nothing is playing).
class CurrentSongNotifier extends Notifier<SongModel?> {
  @override
  SongModel? build() => null;

  void set(SongModel? song) => state = song;
}

final currentSongProvider =
    NotifierProvider<CurrentSongNotifier, SongModel?>(CurrentSongNotifier.new);

/// "Why this song?" reason for the current pick (set on autoplay, cleared on a
/// manual play).
class NowPlayingReasonNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? reason) => state = reason;
}

final nowPlayingReasonProvider =
    NotifierProvider<NowPlayingReasonNotifier, String?>(
  NowPlayingReasonNotifier.new,
);

final playbackControllerProvider = Provider<PlaybackController>((ref) {
  final controller = PlaybackController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class PlaybackController {
  PlaybackController(this._ref) {
    final player = _ref.read(audioPlayerProvider);
    _completionSub = player.processingStateStream.listen((s) {
      if (s == ProcessingState.completed) {
        unawaited(_onCompleted());
      }
    });
  }

  final Ref _ref;
  StreamSubscription<ProcessingState>? _completionSub;
  bool _advancing = false;

  /// Load and start a song. Prefers the content:// URI (robust under scoped
  /// storage), falling back to the raw file path. [reason] is the recommender's
  /// explanation for an autoplay pick.
  Future<void> playSong(
    SongModel song, {
    String context = 'manual',
    String? reason,
  }) async {
    final player = _ref.read(audioPlayerProvider);
    _ref.read(currentSongProvider.notifier).set(song);
    _ref.read(nowPlayingReasonProvider.notifier).set(reason);

    final uri = song.uri;
    if (uri != null && uri.isNotEmpty) {
      await player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
    } else {
      await player.setFilePath(song.data);
    }
    await player.play();
    unawaited(_recordPlay(song, context));
  }

  Future<void> togglePlayPause() async {
    final player = _ref.read(audioPlayerProvider);
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  /// Manually skip to the recommended next song.
  Future<void> skipToNext() => _onCompleted();

  Future<void> _recordPlay(SongModel song, String context) async {
    try {
      final repo = await SongRepository.open();
      final isar = await repo.byFilePath(song.data);
      if (isar == null) return; // not yet scanned into Isar
      final events = await PlayEventRepository.open();
      await events.record(songId: isar.id, context: context);
    } catch (_) {
      // Play-history recording is best-effort.
    }
  }

  /// On completion (or manual skip), ask the recommender for the next song and
  /// play it. No-op if the current song isn't enriched or nothing qualifies.
  Future<void> _onCompleted() async {
    if (_advancing) return;
    _advancing = true;
    try {
      final current = _ref.read(currentSongProvider);
      if (current == null) return;

      final repo = await SongRepository.open();
      final isar = await repo.byFilePath(current.data);
      if (isar == null) return;

      final recommender = await RecommenderService.open();
      final rec = await recommender.nextAfter(isar.id);
      if (rec == null) return;

      final models =
          _ref.read(songsProvider).asData?.value ?? const <SongModel>[];
      SongModel? next;
      for (final m in models) {
        if (m.data == rec.song.filePath) {
          next = m;
          break;
        }
      }
      if (next == null) return;

      await playSong(next, context: 'autoplay', reason: rec.reason);
    } catch (_) {
      // Autoplay is best-effort; a failure just stops playback.
    } finally {
      _advancing = false;
    }
  }

  void dispose() {
    _completionSub?.cancel();
  }
}
