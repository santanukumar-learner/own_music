import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../data/models/song.dart';
import '../data/song_repository.dart';
import '../settings/settings_providers.dart';

/// Progress of a scan + enrichment pass.
class EnrichmentProgress {
  const EnrichmentProgress({
    this.running = false,
    this.total = 0,
    this.done = 0,
    this.failed = 0,
    this.message,
  });

  final bool running;
  final int total;
  final int done;
  final int failed;
  final String? message;

  double get fraction => total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

  EnrichmentProgress copyWith({
    bool? running,
    int? total,
    int? done,
    int? failed,
    String? message,
  }) =>
      EnrichmentProgress(
        running: running ?? this.running,
        total: total ?? this.total,
        done: done ?? this.done,
        failed: failed ?? this.failed,
        message: message ?? this.message,
      );
}

/// Orchestrates LibraryScan + MetadataEnrichment from the UI: mirror the
/// device's tracks into Isar, then upload each to the LAN service (bounded
/// concurrency) to fill in feature vectors. (The WorkManager-scheduled version
/// is deliverable 5 proper; this is the user-triggered foreground pass.)
class EnrichmentController extends Notifier<EnrichmentProgress> {
  static const int _concurrency = 4;

  @override
  EnrichmentProgress build() => const EnrichmentProgress();

  Future<void> scanAndEnrich(List<SongModel> models) async {
    if (state.running) return;

    final client = ref.read(enrichmentClientProvider);
    if (client == null) {
      state = const EnrichmentProgress(
        message: 'Set the enrichment service URL in Settings first.',
      );
      return;
    }

    state = const EnrichmentProgress(running: true, message: 'Scanning library…');
    final repo = await SongRepository.open();

    // 1. Mirror the library into Isar (raw rows).
    for (final m in models) {
      await repo.upsertScanned(
        filePath: m.data,
        fileName: m.displayNameWOExt,
        title: m.title,
        artist: m.artist,
        album: m.album,
        durationMs: m.duration ?? 0,
        addedAt: DateTime.fromMillisecondsSinceEpoch(
          (m.dateAdded ?? 0) * 1000,
        ),
      );
    }

    // 2. Check the service is reachable before uploading anything.
    state = state.copyWith(message: 'Connecting to ${client.baseUrl}…');
    if (!await client.ping()) {
      state = EnrichmentProgress(
        message: 'Service unreachable at ${client.baseUrl}. '
            'Is uvicorn running and the phone on the same Wi-Fi?',
      );
      return;
    }

    // 3. Enrich pending songs with bounded concurrency.
    final pending = await repo.pendingEnrichment(limit: 1 << 30);
    state = EnrichmentProgress(
      running: true,
      total: pending.length,
      message: 'Enriching ${pending.length} tracks…',
    );

    final queue = List<Song>.of(pending);
    var done = 0;
    var failed = 0;

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final song = queue.removeLast();
        try {
          final result = await client.enrichFile(
            song.filePath,
            title: song.title,
            artist: song.artist,
            album: song.album,
            genre: song.genres.isNotEmpty ? song.genres.first : null,
          );
          await repo.applyEnrichment(song.id, result);
          if (result.failed) failed++;
        } catch (_) {
          failed++;
        }
        done++;
        state = state.copyWith(done: done, failed: failed);
      }
    }

    await Future.wait([for (var i = 0; i < _concurrency; i++) worker()]);

    final ok = done - failed;
    state = EnrichmentProgress(
      total: pending.length,
      done: done,
      failed: failed,
      message: 'Enriched $ok of ${pending.length}'
          '${failed > 0 ? ' ($failed failed)' : ''}.',
    );
  }
}

final enrichmentControllerProvider =
    NotifierProvider<EnrichmentController, EnrichmentProgress>(
  EnrichmentController.new,
);
